local peripherals = {}

for _, v in pairs(peripheral.getNames() do
	if not peripherals[peripheral.getType(v)] then
		peripherals[peripheral.getType(v)] = {}
	end
	table.insert(peripherals[peripheral.getType(v)], v)
end

for pType, v in pairs(peripherals) do
	print(pType..":")
	textutils.pagedTabulate(v)
end