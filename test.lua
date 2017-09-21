local xml = require('xml-parser')

local value = [[
	<?xml version='1.0' encoding='UTF-8'?>
	<Envelop>
		<Foo></Foo>
		<Bar>
			<NS:Foo></NS:Foo>
		</Bar>
	</Envelop>
]]

local xmlValue = xml.parse(value)

assert(xmlValue.name == 'Envelop', 'oops, something went wrong.')

assert(xmlValue.children[1].name == 'Foo', 'oops, something went wrong.')

assert(xmlValue.children[2].name == 'Bar', 'oops, something went wrong.')

assert(xmlValue.children[2].children[1].name == 'NS:Foo', 'oops, something went wrong.')

print('Tests passed.')