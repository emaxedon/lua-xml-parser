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

--[[
	Takes an XML table and returns a decoded pretty string.
]]
function xml.prettyPrint(value)
	local result = string.format('<%s>\n', value.name)

	function printChildren(children, depth)
		if not children or #children == 0 then
			return nil
		end

		local spaces = string.rep('    ', depth)

		for k, v in pairs(children) do
			if not v.empty then
				if not v.children or #v.children == 0 then
					result = result .. string.format('%s<%s></%s>\n', spaces, v.name, v.name)
				else
					result = result .. string.format('%s<%s>\n', spaces, v.name)

					printChildren(v.children, depth + 1)

					result = result .. string.format('%s</%s>\n', spaces, v.name)
				end
			else
				result = result .. string.format('%s<%s/>\n', spaces, v.name)
			end
		end
	end

	printChildren(value.children, 1)

	result = result .. string.format('</%s>', value.name)

	return result
end

return xml