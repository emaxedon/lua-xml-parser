--[[
	XML Parser

	Author: Edward Maxedon
]]

xml = {}

function xml.parse(value)
	local i = 1

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
				return {
					name = startTag.name,
					children = children
				}
			else
				error(string.format('mismatched start and end tags: %s, %s', startTag.name, endTag))
			end
		end
	end

	return parseElement()
end

return xml