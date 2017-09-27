--[[
	XML Parser

	Author: Edward Maxedon
]]

xml = {}

--[[
	Parses XML text into a table.
]]
function xml.parse(value)
	local i = 1

	function parseAttributes(value)
		local attributes = {}

		string.gsub(value, '(%w+)=(["\'])(.-)%2', function(n, _, v)
			attributes[n] = v
		end)

		return attributes
	end

	function parseStartTag()
		local ni, j, c, name, attributes, empty = string.find(value, '<(/?)([%w_:]+)(.-)(/?)>', i)

		if not ni then
			return nil
		elseif c == '/' then
			return nil
		else
			i = j + 1

			return {
				name = name,
				attributes = parseAttributes(attributes),
				empty = (empty == '/')
			}
		end
	end

	function parseEndTag()
		local ni, j, name = string.find(value, '</([%w_:]+)>', i)

		if not ni then
			return nil
		else
			i = j + 1

			return name
		end
	end

	function parseElement()
		local startTag = parseStartTag()

		if not startTag then
			return nil
		elseif startTag.empty then
			return startTag
		else
			local children = {}

			while true do
				local element = parseElement()

				if element then
					table.insert(children, element)
				else
					break
				end
			end

			local endTag = parseEndTag()

			if startTag.name == endTag then
				local find = function (self, name)
					if not self.children or #self.children == 0 then
						return nil
					end

					for i, v in ipairs(self.children) do
						if v.name == name then
							return self.children[i]
						elseif i == #self.children then
							return nil
						end
					end
				end

				return {
					name = startTag.name,
					attributes = startTag.attributes,
					children = children,
					find = find
				}
			else
				error(string.format('mismatched start and end tags: %s, %s', startTag.name, endTag))
			end
		end
	end

	return parseElement()
end

local function encodeXMLEntities(value)
	value = string.gsub(value, '&', '&amp;')
	value = string.gsub(value, '<', '&lt;')
	value = string.gsub(value, '>', '&gt;')
	value = string.gsub(value, '"', '&quot;')
	value = string.gsub(value, '([^%w%&%;%p%\t% ])', function(c)
		return string.format('&#x%X;', string.byte(c))
	end)
	return value
end

local function decodeXMLEntities(value)
	value = string.gsub(value, '&#x([%x]+)%;', function(h)
		return string.char(tonumber(h, 16))
	end)
	value = string.gsub(value, '&#([0-9]+)%;', function(h)
		return string.char(tonumber(h, 10))
	end)
	value = string.gsub(value, '&quot;', '"')
	value = string.gsub(value, '&apos;', '\'')
	value = string.gsub(value, '&gt;', '>')
	value = string.gsub(value, '&lt;', '<')
	value = string.gsub(value, '&amp;', '&')
	return value
end

--[[
	Takes an XML table and returns a decoded pretty string.
]]
function xml.prettyPrint(value)
	function printAttributes(attributes)
		local result = ''

		for k, v in pairs(attributes) do
			result = result .. string.format(' %s="%s"', k, decodeXMLEntities(v))
		end

		return result
	end

	local result = string.format('<%s%s>\n', value.name, printAttributes(value.attributes))

	function printChildren(children, depth)
		if not children or #children == 0 then
			return nil
		end

		local spaces = string.rep('    ', depth)

		for k, v in pairs(children) do
			local decodedAttributes = printAttributes(v.attributes)

			if not v.empty then
				if not v.children or #v.children == 0 then
					result = result .. string.format('%s<%s%s></%s>\n', spaces, v.name, decodedAttributes, v.name)
				else
					result = result .. string.format('%s<%s%s>\n', spaces, v.name, decodedAttributes)

					printChildren(v.children, depth + 1)

					result = result .. string.format('%s</%s>\n', spaces, v.name)
				end
			else
				result = result .. string.format('%s<%s%s/>\n', spaces, v.name, decodedAttributes)
			end
		end
	end

	printChildren(value.children, 1)

	result = result .. string.format('</%s>', value.name)

	return result
end

return xml