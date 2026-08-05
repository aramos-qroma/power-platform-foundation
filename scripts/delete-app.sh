#!/bin/bash
# Elimina UNA canvas app vía Power Apps admin API (az + curl, sin pwsh/pac).
# Uso: delete-app.sh -a <appId|displayName> [-e <envId>] [-n] [-y]
#   -n dry-run (resuelve y muestra, no borra)   -y sin confirmación
# Registro pre-delete: scripts/deleted-apps.jsonl
set -euo pipefail

API_VER="2017-08-01"
DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$DIR/deleted-apps.jsonl"

APP="" ENV_ID="" DRY=0 YES=0
while getopts "a:e:ny" opt; do
  case $opt in
    a) APP="$OPTARG" ;;
    e) ENV_ID="$OPTARG" ;;
    n) DRY=1 ;;
    y) YES=1 ;;
    *) exit 2 ;;
  esac
done
[ -n "$APP" ] || { echo "Uso: $0 -a <appId|displayName> [-e <envId>] [-n] [-y]" >&2; exit 2; }

TOK=$(az account get-access-token --resource https://service.powerapps.com/ --query accessToken -o tsv)

# Sin -e: usa el environment Default del tenant
if [ -z "$ENV_ID" ]; then
  ENV_ID=$(curl -sf -H "Authorization: Bearer $TOK" \
    "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?api-version=2020-10-01" \
    | python3 -c 'import json,sys; print(next(e["name"] for e in json.load(sys.stdin)["value"] if e["properties"].get("isDefault")))')
fi

APPS_URL="https://api.powerapps.com/providers/Microsoft.PowerApps/scopes/admin/environments/$ENV_ID/apps"

# Resuelve appId: GUID directo, o displayName con match único (sigue nextLink)
META=$(TOK="$TOK" python3 -c '
import json,os,sys,urllib.request
target=sys.argv[1]
apps=[]; url=sys.argv[3]
while url:
    req=urllib.request.Request(url,headers={"Authorization":"Bearer "+os.environ["TOK"]})
    with urllib.request.urlopen(req,timeout=60) as r: d=json.load(r)
    apps+=d.get("value",[]); url=d.get("nextLink")
guid=len(target)==36 and target.count("-")==4
hits=[a for a in apps if (a["name"]==target if guid else a["properties"].get("displayName","").strip().lower()==target.strip().lower())]
if len(hits)!=1:
    print(f"ERROR: {len(hits)} coincidencias para {target!r}", file=sys.stderr)
    for a in hits: print(f"  {a['name']}  {a['properties'].get('displayName')}", file=sys.stderr)
    sys.exit(1)
a=hits[0]; p=a["properties"]
print(json.dumps({"appId":a["name"],"displayName":p.get("displayName"),
  "owner":(p.get("owner") or {}).get("displayName"),"env":sys.argv[2],
  "modified":(p.get("lastModifiedTime") or "")[:10],
  "sharedUsers":p.get("sharedUsersCount"),"sharedGroups":p.get("sharedGroupsCount")},ensure_ascii=False))
' "$APP" "$ENV_ID" "$APPS_URL?api-version=$API_VER")

echo "$META" | python3 -m json.tool
APP_ID=$(echo "$META" | python3 -c 'import json,sys; print(json.load(sys.stdin)["appId"])')

[ "$DRY" -eq 1 ] && { echo "[dry-run] no se elimina"; exit 0; }

if [ "$YES" -ne 1 ]; then
  printf "Eliminar esta app? (yes/no): "
  read -r ans
  [ "$ans" = "yes" ] || { echo "cancelado"; exit 1; }
fi

echo "$META" >> "$LOG"
HTTP=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE -H "Authorization: Bearer $TOK" \
  "$APPS_URL/$APP_ID?api-version=$API_VER")
echo "DELETE HTTP $HTTP"
[ "$HTTP" = "200" ] || [ "$HTTP" = "202" ] || [ "$HTTP" = "204" ] || { echo "ERROR: delete falló" >&2; exit 1; }

# Verifica que ya no exista
VHTTP=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOK" \
  "$APPS_URL/$APP_ID?api-version=$API_VER")
[ "$VHTTP" = "404" ] && echo "verificado: app eliminada (GET 404)" || echo "aviso: GET post-delete devolvió $VHTTP"
