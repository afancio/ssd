import("gis")

inputLayerName  = "brasil"
outputLayerName = "brasilCells_500x500"
proj = Project{
    file = "covid_brasil_terrame.tview",
}

brasilCells = Layer{
	project = proj, 
	name = outputLayerName
}

brasilCells:fill{
	operation = "sum",
	layer = inputLayerName,
	attribute = "population",
	select = "agreount_",
	area = true
}

cell = Cell{
	clean = true,
    logpop = function(self)
        return math.log(self.population)
    end
}       
    
cs = CellularSpace{
    project = proj,
    layer = outputLayerName,
    instance = cell
}

Map{
    target = cs,
    select = "logpop",
    slices = 10,
    color = "Purples"
}

forEachCell(cs, function(cell) 
	for k,v in pairs(cell) do
		print(k,v)	
	end
	return false
end)