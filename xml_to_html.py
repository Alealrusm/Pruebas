import os
import xml.etree.ElementTree as ET
from pathlib import Path

def parse_xml_to_html(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    name = root.attrib.get("name", "")
    inherits = root.attrib.attrib.get("inherits", "") if hasattr(root.attrib, 'attrib') else root.attrib.get("inherits", "")
    brief = ""
    description = ""
    signals = []
    methods = []
    members = []

    for child in root:
        if child.tag == "brief_description":
            brief = (child.text or "").strip()
        elif child.tag == "description":
            description = (child.text or "").strip()
        elif child.tag == "signals":
            for sig in child:
                sname = sig.attrib.get("name", "")
                sdesc = ""
                sparams = []
                for sc in sig:
                    if sc.tag == "description":
                        sdesc = (sc.text or "").strip()
                    elif sc.tag == "param":
                        sparams.append(f"{sc.attrib.get('name','')} : {sc.attrib.get('type','')}")
                signals.append((sname, sparams, sdesc))
        elif child.tag == "methods":
            for method in child:
                mname = method.attrib.get("name", "")
                mreturn = ""
                mparams = []
                mdesc = ""
                for mc in method:
                    if mc.tag == "return":
                        mreturn = mc.attrib.get("type", "void")
                    elif mc.tag == "param":
                        mparams.append(f"{mc.attrib.get('name','')} : {mc.attrib.get('type','')}")
                    elif mc.tag == "description":
                        mdesc = (mc.text or "").strip()
                methods.append((mname, mparams, mreturn, mdesc))
        elif child.tag == "members":
            for member in child:
                mname = member.attrib.get("name", "")
                mtype = member.attrib.get("type", "")
                mdesc = (member.text or "").strip()
                members.append((mname, mtype, mdesc))

    html = f"""
    <div class="class-block">
        <h2 class="class-name">{name}</h2>
        {"<p class='inherits'>Hereda de: <code>" + inherits + "</code></p>" if inherits else ""}
        {"<p class='brief'>" + brief + "</p>" if brief else ""}
        {"<p class='description'>" + description + "</p>" if description else ""}
    """

    if signals:
        html += "<h3>Señales</h3><table><tr><th>Nombre</th><th>Parámetros</th><th>Descripción</th></tr>"
        for sname, sparams, sdesc in signals:
            html += f"<tr><td><code>{sname}</code></td><td>{', '.join(sparams) or '—'}</td><td>{sdesc}</td></tr>"
        html += "</table>"

    if members:
        html += "<h3>Variables</h3><table><tr><th>Nombre</th><th>Tipo</th><th>Descripción</th></tr>"
        for mname, mtype, mdesc in members:
            html += f"<tr><td><code>{mname}</code></td><td><code>{mtype}</code></td><td>{mdesc}</td></tr>"
        html += "</table>"

    if methods:
        html += "<h3>Métodos</h3>"
        for mname, mparams, mreturn, mdesc in methods:
            params_str = ", ".join(mparams) or ""
            html += f"""
            <div class="method-block">
                <p class="method-sig"><code>{mreturn} {mname}({params_str})</code></p>
                {"<p class='method-desc'>" + mdesc + "</p>" if mdesc else ""}
            </div>"""

    html += "</div><hr>"
    return name, html


def main():
    docs_dir = Path("docs")
    xml_files = list(docs_dir.glob("*.xml"))

    if not xml_files:
        print("No se encontraron XMLs en la carpeta docs/")
        return

    classes_html = []
    toc_items = []

    for xml_file in sorted(xml_files):
        try:
            name, html = parse_xml_to_html(xml_file)
            classes_html.append(html)
            toc_items.append(f'<li><a href="#{name}">{name}</a></li>')
            print(f"Procesado: {xml_file.name}")
        except Exception as e:
            print(f"Saltando {xml_file.name}: {e}")

    full_html = f"""<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Documentación del Proyecto</title>
    <style>
        body {{ font-family: Segoe UI, sans-serif; max-width: 960px; margin: 40px auto; padding: 0 20px; background: #1e1e2e; color: #cdd6f4; }}
        h1 {{ color: #cba6f7; border-bottom: 2px solid #cba6f7; padding-bottom: 8px; }}
        h2.class-name {{ color: #89b4fa; margin-top: 0; }}
        h3 {{ color: #a6e3a1; }}
        .class-block {{ background: #313244; border-radius: 8px; padding: 20px; margin-bottom: 30px; }}
        .inherits {{ color: #fab387; font-size: 0.9em; }}
        .brief {{ font-weight: bold; }}
        table {{ width: 100%; border-collapse: collapse; margin: 10px 0; }}
        th {{ background: #45475a; padding: 8px; text-align: left; }}
        td {{ padding: 8px; border-bottom: 1px solid #45475a; vertical-align: top; }}
        code {{ background: #45475a; padding: 2px 6px; border-radius: 4px; font-family: Consolas, monospace; color: #f38ba8; }}
        .method-block {{ background: #1e1e2e; border-radius: 6px; padding: 12px; margin: 8px 0; }}
        .method-sig code {{ color: #89dceb; }}
        nav {{ background: #313244; border-radius: 8px; padding: 16px; margin-bottom: 30px; }}
        nav ul {{ columns: 3; list-style: none; padding: 0; margin: 0; }}
        nav a {{ color: #89b4fa; text-decoration: none; }}
        nav a:hover {{ text-decoration: underline; }}
        hr {{ border: none; border-top: 1px solid #45475a; }}
    </style>
</head>
<body>
    <h1>Documentación del Proyecto</h1>
    <nav>
        <h3 style="margin-top:0">Clases</h3>
        <ul>{''.join(toc_items)}</ul>
    </nav>
    {''.join(classes_html)}
</body>
</html>"""

    out_path = Path("docs/documentacion.html")
    out_path.write_text(full_html, encoding="utf-8")
    print(f"\nGenerado: {out_path.resolve()}")

if __name__ == "__main__":
    main()
