import xml.etree.ElementTree as ET

ET.register_namespace('', 'http://www.w3.org/2000/svg')
ET.register_namespace('xlink', 'http://www.w3.org/1999/xlink')

tree = ET.parse(r'C:/Users/Welcome/Downloads/file.svg')
root = tree.getroot()

# Remove any top-level path with a solid white fill — that is the background rect
to_remove = []
for child in root:
    tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
    fill = child.get('fill', '').upper()
    opacity = child.get('opacity', '1')
    if tag == 'path' and fill in ('#FFFFFF', '#FFF', 'WHITE') and opacity == '1.000000':
        to_remove.append(child)
        print('Removing white background path')

for el in to_remove:
    root.remove(el)

print(f'Removed {len(to_remove)} path(s). Remaining children: {len(list(root))}')

out = r'C:/Users/Welcome/eddy-app/assets/illustrations/momentum_empty_state.svg'
tree.write(out, xml_declaration=True, encoding='unicode')
print('Saved to', out)
