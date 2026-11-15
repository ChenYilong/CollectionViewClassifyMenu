"""
Mirror-only patch of Flutter-OHOS's OhosAutoFillHelper.ets for SDKs without autoFillManager's fill types (API < 26).
The helper already refuses at run time below API 26; this removes the code after that gate so it compiles.
"""
import re, sys
p = sys.argv[1]
s = open(p).read()

def body_span(src, header):
    i = src.index(header)
    j = src.index('{', src.index(')', i))
    depth, k = 0, j
    while True:
        if src[k] == '{': depth += 1
        elif src[k] == '}':
            depth -= 1
            if depth == 0: return j, k
        k += 1

for name, stub in [
    ('static requestAutoFill(', "{\n    onFailure(-1);\n  }"),
    ('static requestAutoSave(', "{\n    napiCallback.onFailure();\n  }"),
    ('private static toManagerViewData(', "{\n    return OhosAutoFillHelper.toManagerViewDataShape(viewData);\n  }"),
    ('private static toSdkAutoFillType(', "{\n    return value;\n  }"),
    ('static parseFillResult(', "{\n    const values: Map<number, string> = new Map();\n    for (const node of viewData.pageNodeInfos) {\n      if (node.value.length > 0) {\n        values.set(node.id, node.value);\n      }\n    }\n    return values;\n  }"),
]:
    a, b = body_span(s, name)
    s = s[:a] + stub + s[b + 1:]
s = s.replace('private static toSdkAutoFillType(value: number): autoFillManager.AutoFillType', 'private static toSdkAutoFillType(value: number): number')
s = s.replace('private static toManagerViewData(viewData: OhosViewData): autoFillManager.ViewData', 'private static toManagerViewData(viewData: OhosViewData): OhosViewData')
s = s.replace('static parseFillResult(viewData: autoFillManager.ViewData)', 'static parseFillResult(viewData: OhosViewData)')
s = s.replace('return OhosAutoFillHelper.toManagerViewDataShape(viewData);', 'return viewData;')
open(p, 'w').write(s)
left = [l for l in s.splitlines() if 'autoFillManager.' in l]
print('\n'.join(left))
