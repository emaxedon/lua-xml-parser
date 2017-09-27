# Lua XML Parser

## Installation

Copy the `xml-parser.lua` file to your project's root directory, then import the module.

`local xml = require('xml-parser.lua')`

## Example

```
local xml = require('xml-parser.lua')

local xmlString = [[
	<Envelop>
		<Foo></Foo>
		<Bar ID="101"></Bar>
	</Evenlop>
]]

local xmlTable = xml.parse(xmlString)

print(xmlTable.children[1].name)
-- Output:
-- Foo

print(xmlTable:find('Bar').attributes['ID'])
-- Output:
-- 101

print(xml.prettyPrint(xmlTable))
-- Output:
-- <Envelop>
--     <Foo></Foo>
--     <Bar ID="101"></Bar>
-- </Evenlop>
```

## License

Lua XML Parser is distributed under the MIT License, meaning that you are free to use it in your free or proprietary software.