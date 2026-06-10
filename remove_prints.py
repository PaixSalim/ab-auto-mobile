import os
import re

def remove_prints(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = ""
    i = 0
    while i < len(content):
        # find 'print(' or 'log('
        # Make sure it's not part of a larger word
        match_print = content[i:].startswith('print(') and (i == 0 or not content[i-1].isalnum() and content[i-1] != '_')
        match_log = content[i:].startswith('log(') and (i == 0 or not content[i-1].isalnum() and content[i-1] != '_')
        
        # Avoid matching 'log(' if it's actually part of 'math.log(' or something
        # For our purposes we assume 'print(' and 'log(' are the targets.
        
        if match_print or match_log:
            if match_print:
                start = i + 5 # index of '('
            else:
                start = i + 3 # index of '('
                
            paren_count = 1
            j = start + 1
            in_string = False
            string_char = ''
            while j < len(content) and paren_count > 0:
                if content[j] == '\\':
                    j += 2
                    continue
                if not in_string and (content[j] == '"' or content[j] == "'"):
                    in_string = True
                    string_char = content[j]
                elif in_string and content[j] == string_char:
                    in_string = False
                elif not in_string:
                    if content[j] == '(':
                        paren_count += 1
                    elif content[j] == ')':
                        paren_count -= 1
                j += 1
            
            # Now j is at the char after ')'
            # Check if there is a semicolon
            if j < len(content) and content[j] == ';':
                j += 1
                
            # remove spaces/tabs after semicolon if rest of line is empty
            k = j
            while k < len(content) and content[k] in [' ', '\t']:
                k += 1
            if k < len(content) and content[k] == '\n':
                k += 1
                j = k
                
            i = j
        else:
            new_content += content[i]
            i += 1
            
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Removed prints from {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            try:
                remove_prints(os.path.join(root, file))
            except Exception as e:
                print(f"Error processing {file}: {e}")
