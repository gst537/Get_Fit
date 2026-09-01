import re
import sys
import uuid

pbxproj_path = "GetFit.xcodeproj/project.pbxproj"
with open(pbxproj_path, "r") as f:
    content = f.read()

def generate_id():
    return uuid.uuid4().hex[:24].upper()

# Files to add
files = [
    ("ScanMachineSheet.swift", "Views"),
    ("AIMachineVisionService.swift", "Services")
]

for filename, group_name in files:
    if filename in content:
        print(f"{filename} already in project")
        continue
        
    file_ref_id = generate_id()
    build_file_id = generate_id()
    
    # Add PBXBuildFile
    build_file_str = f"		{build_file_id} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {filename} */; }};\n"
    content = re.sub(r'(/\* End PBXBuildFile section \*/)', r'\1', content) # just to anchor
    content = content.replace('/* End PBXBuildFile section */', f'{build_file_str}/* End PBXBuildFile section */')
    
    # Add PBXFileReference
    file_ref_str = f"		{file_ref_id} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};\n"
    content = content.replace('/* End PBXFileReference section */', f'{file_ref_str}/* End PBXFileReference section */')
    
    # Add to PBXGroup
    # Find the group
    group_match = re.search(f'\\/\\* {group_name} \\*\\/ = {{\\s*isa = PBXGroup;\\s*children = \\[\n', content)
    if group_match:
        insert_pos = group_match.end()
        content = content[:insert_pos] + f"				{file_ref_id} /* {filename} */,\n" + content[insert_pos:]
    else:
        print(f"Could not find group {group_name}")
        
    # Add to PBXSourcesBuildPhase
    sources_match = re.search(r'/\* Begin PBXSourcesBuildPhase section \*/[\s\S]*?files = \(\n', content)
    if sources_match:
        insert_pos = sources_match.end()
        content = content[:insert_pos] + f"				{build_file_id} /* {filename} in Sources */,\n" + content[insert_pos:]

with open(pbxproj_path, "w") as f:
    f.write(content)
print("Patched successfully")
