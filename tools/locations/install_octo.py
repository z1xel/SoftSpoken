"""Install the fixed generated catalog from Octo_Fixed_Catalog.zip into L6."""
import argparse
import hashlib
from pathlib import Path
import zipfile

EXPECTED = {
    # Filled with the exact fixed L4/L5 Lua data digests.
}

def install(archive, root):
    root=Path(root).resolve()
    target=root/"SoftSpoken"/"Locations"/"Data.lua"
    if not (target.parent/"Registry.lua").is_file():
        raise ValueError("L6 registry not installed; update dev first")
    with zipfile.ZipFile(archive) as z:
        parts=[]
        for name, expected in EXPECTED.items():
            data=z.read(name)
            if hashlib.sha256(data).hexdigest()!=expected:
                raise ValueError(f"unexpected fixed catalog member: {name}")
            parts.append(data.decode("utf-8"))
    output="setfenv(1, SpokenEnv)\n\n"+"".join(p.rstrip()+"\n" for p in parts)
    temp=target.with_suffix(".tmp")
    temp.write_bytes(output.encode("utf-8"))
    temp.replace(target)
    return target

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog",type=Path,required=True)
    parser.add_argument("--root",type=Path,default=Path(__file__).resolve().parents[2])
    args=parser.parse_args()
    print(f"Installed {install(args.catalog,args.root)}")

if __name__=="__main__":
    main()
