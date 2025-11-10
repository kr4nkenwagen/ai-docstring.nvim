local c = {}
c.key = "<leader>od"
c.ai = {
	model = "mistral:7b",
	system = "You are a senior developer tasked with writing a docstring for the following funcion. Only write the docstring. Nothing else. do not write code. ",
	serve = true,
}
return c
