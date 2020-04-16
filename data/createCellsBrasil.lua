import("gis")

DATA_PATH = "C:/COVID_19_Models/Dados/vetor_EstadosBR_LLWGS84"

proj = Project{
    file = "covid_brasil_terrame.tview",
	clean = true
}

brasil = Layer{
	project = proj, 
	file = DATA_PATH.."/".."EstadosBR_IBGE_LLWGS84.shp",
	name = "brasil"
}

brasilCells = Layer{
    project = proj,
    name = "brasilCells_500x500",
    file = "brasilCells_500x500.shp",
    input = "brasil",
    resolution = 0.5
}