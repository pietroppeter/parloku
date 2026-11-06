"""Lists candidate pictures for the gallery: every freely licensed (Wikimedia Commons) JPEG or PNG used on the
Wikipedia articles of the twenty artists and some of their works, with author, licence and a 500px thumbnail URL.
Writes candidates.json next to this file (not committed). images.json, which the page reads, was picked from it by
hand: one entry per gallery work, "<style id>/<work title>": {src, page, file, credit, license}.
The page hotlinks `src`, so nothing is copied into the repo. Use standard thumbnail widths (500px here):
Wikimedia refuses other sizes when it is busy. Run: python3 src/devlog_styles/fetch_images.py
"""
import json, time, urllib.parse, urllib.request
from pathlib import Path

UA = "parloku-devlog-builder/0.1 (https://github.com/pietroppeter/parloku)"
articles = ["Enzo Mari", "Yayoi Kusama", "Raoul Dufy", "Josef Albers", "Giorgio Morandi", "Mitsumasa Anno",
            "Niki de Saint Phalle", "Roberto Burle Marx", "Fortunato Depero", "Ikko Tanaka", "Alain Grée",
            "Esther Mahlangu", "Emanuele Luzzati", "Hilma af Klint", "Corita Kent", "Ettore Sottsass", "Memphis Group",
            "Luis Barragán", "Alma Siedhoff-Buscher", "Agnes Martin", "Bhajju Shyam", "Tarot Garden",
            "Stravinsky Fountain", "Sítio Roberto Burle Marx", "Copacabana Beach", "Luis Barragán House and Studio",
            "Rainbow Swash", "Homage to the Square", "Muji"]
params = {"action": "query", "titles": "|".join(articles), "generator": "images", "gimlimit": "max",
          "prop": "imageinfo", "iiprop": "url|extmetadata|mime", "iiurlwidth": 500,
          "format": "json", "formatversion": 2, "redirects": 1}
found, cont = {}, {}
while True:
    url = "https://en.wikipedia.org/w/api.php?" + urllib.parse.urlencode({**params, **cont})
    for wait in (0, 30, 60, 120, 240):
        time.sleep(wait)
        try:
            body = urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": UA}), timeout=30).read()
            data = json.loads(body)
            break
        except Exception as e:
            print("retry:", e)
    else:
        raise SystemExit("Wikipedia keeps refusing; try again later")
    for p in data.get("query", {}).get("pages", []):
        ii = (p.get("imageinfo") or [{}])[0]
        if "/commons/" in ii.get("url", "") and ii.get("mime") in ("image/jpeg", "image/png"):
            md = ii.get("extmetadata", {})
            found[p["title"]] = {"src": ii.get("thumburl", "").split("?")[0], "page": ii["descriptionurl"],
                                 "credit": md.get("Artist", {}).get("value", ""),
                                 "license": md.get("LicenseShortName", {}).get("value", "")}
    if "continue" not in data:
        break
    cont = data["continue"]
    time.sleep(5)
(Path(__file__).parent / "candidates.json").write_text(json.dumps(found, indent=1, ensure_ascii=False))
print(len(found), "candidates")
