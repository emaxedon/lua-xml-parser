# Lua XML Parser

## Installation

Copy the `xml-parser.lua` file to your project root directory, then import the module.

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
-- Result: Foo

print(xmlTable.children[2].attributes['ID'])
-- Result: 101
```