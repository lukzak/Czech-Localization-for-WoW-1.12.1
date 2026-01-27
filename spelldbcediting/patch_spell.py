import csv

spell_file = 'spell.csv'
merged_file = 'spell_Auras_descriptions.csv'
output_file = 'spell_updated.csv'

# Load spell changes
updates = {}
with open(merged_file, newline='', encoding='utf-8') as f:
    reader = csv.reader(f, skipinitialspace=True)
    for row in reader:
        if not row:
            continue
        id_ = row[0]
        new_138 = row[1] if len(row) > 1 else ''
        new_147 = row[2] if len(row) > 2 else ''
        updates[id_] = (new_138, new_147)

# Replace cells with localizations and export new file for import into spell.dbc
with open(spell_file, newline='', encoding='utf-8') as f_in, \
     open(output_file, 'w', newline='', encoding='utf-8') as f_out:

    reader = csv.reader(f_in)
    writer = csv.writer(f_out, quoting=csv.QUOTE_MINIMAL)

    for row in reader:
        if not row:
            writer.writerow(row)
            continue

        id_ = row[0]
        if id_ in updates:
            new_138, new_147 = updates[id_]

            # Ensure row is long enough for 138 and 147
            while len(row) <= max(138, 147):
                row.append('')

            
            row[138] = new_138
            row[147] = new_147

            # trailing empty cells preserved
            original_length = len(row)
            if len(row) < original_length:
                row.extend([''] * (original_length - len(row)))

        writer.writerow(row)
