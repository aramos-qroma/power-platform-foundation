#!/bin/bash
# Pull completo (paginado) de apps + flows del entorno Default para auditoría.
# Uso: pull-default-audit.sh <outDir>
set -euo pipefail

OUT="${1:?uso: pull-default-audit.sh <outDir>}"
mkdir -p "$OUT"
ENV_ID="Default-faed75e0-b942-4b73-85ac-7a32b852ceb8"

PTOK=$(az account get-access-token --resource https://service.powerapps.com/ --query accessToken -o tsv)
FTOK=$(az account get-access-token --resource https://service.flow.microsoft.com/ --query accessToken -o tsv)
GTOK=$(az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)

export OUT ENV_ID PTOK FTOK GTOK
python3 <<'EOF'
import json, os, time, urllib.request, urllib.error

OUT, ENV = os.environ["OUT"], os.environ["ENV_ID"]

def get(url, tok, retries=4):
    for i in range(retries):
        try:
            req = urllib.request.Request(url, headers={"Authorization": f"Bearer {tok}"})
            with urllib.request.urlopen(req, timeout=90) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 502, 503, 504) and i < retries - 1:
                time.sleep(2 ** (i + 1)); continue
            raise

def get_all(url, tok):
    out, pages = [], 0
    while url:
        d = get(url, tok)
        out += d.get("value", []); pages += 1
        url = d.get("nextLink")
    return out, pages

apps, p = get_all(f"https://api.powerapps.com/providers/Microsoft.PowerApps/scopes/admin/environments/{ENV}/apps?api-version=2017-08-01", os.environ["PTOK"])
print(f"apps: {len(apps)} en {p} paginas")
with_cr = sum(1 for a in apps if "connectionReferences" in a.get("properties", {}))
print(f"apps con connectionReferences: {with_cr}/{len(apps)}")
if with_cr == 0:
    print("WARN: sin connectionReferences en list — se requiere fallback GET por app")
json.dump(apps, open(f"{OUT}/apps-default-untrimmed.json", "w"), ensure_ascii=False)

flows, p = get_all(f"https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/scopes/admin/environments/{ENV}/v2/flows?api-version=2016-11-01", os.environ["FTOK"])
print(f"flows: {len(flows)} en {p} paginas")
with_ds = sum(1 for f in flows if f.get("properties", {}).get("definitionSummary"))
print(f"flows con definitionSummary: {with_ds}/{len(flows)}")
json.dump(flows, open(f"{OUT}/flows-default-full.json", "w"), ensure_ascii=False)

# Resolver GUIDs de creators/owners via Graph $batch (20 por lote)
ids = set()
for f in flows:
    u = (f.get("properties", {}).get("creator") or {}).get("userId")
    if u: ids.add(u)
for a in apps:
    o = a.get("properties", {}).get("owner") or {}
    if o.get("id") and not o.get("displayName"): ids.add(o["id"])
ids = sorted(ids)
users = {}
for i in range(0, len(ids), 20):
    batch = ids[i:i+20]
    body = json.dumps({"requests": [{"id": u, "method": "GET",
        "url": f"/users/{u}?$select=displayName,userPrincipalName,accountEnabled"} for u in batch]}).encode()
    req = urllib.request.Request("https://graph.microsoft.com/v1.0/$batch", data=body,
        headers={"Authorization": f"Bearer {os.environ['GTOK']}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=90) as r:
        for resp in json.load(r)["responses"]:
            if resp["status"] == 200:
                b = resp["body"]
                users[resp["id"]] = {"displayName": b.get("displayName"),
                    "upn": b.get("userPrincipalName"), "enabled": b.get("accountEnabled")}
            else:
                users[resp["id"]] = {"displayName": None, "upn": None, "enabled": None, "deleted": True}
    time.sleep(0.3)
deleted = sum(1 for v in users.values() if v.get("deleted"))
print(f"usuarios resueltos: {len(users)} (eliminados: {deleted})")
json.dump(users, open(f"{OUT}/users-map.json", "w"), ensure_ascii=False)
EOF
echo "PULL DONE"
