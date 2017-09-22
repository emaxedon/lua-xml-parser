local xml = require('xml-parser')

local value = [[
	<?xml version='1.0' encoding='UTF-8'?>
	<Envelop ID="1">
		<Foo></Foo>
		<Bar>
			<NS:Foo ID="2"></NS:Foo>
		</Bar>
	</Envelop>
]]

local xmlValue = xml.parse(value)

assert(xmlValue.name == 'Envelop', 'oops, something went wrong.')

assert(xmlValue.attributes['ID'] == '1', 'oops, something went wrong.')

assert(xmlValue.children[1].name == 'Foo', 'oops, something went wrong.')

assert(xmlValue.children[2].name == 'Bar', 'oops, something went wrong.')

assert(xmlValue.children[2].children[1].name == 'NS:Foo', 'oops, something went wrong.')

assert(xmlValue.children[2].children[1].attributes['ID'] == '2', 'oops, something went wrong.')

print('Tests passed.')