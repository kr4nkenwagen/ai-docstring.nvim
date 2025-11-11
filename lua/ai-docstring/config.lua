local c = {}
c.key = "<leader>od"
c.accept_key = "<leader>"
c.decline_key = "q"
c.renew_key = "r"
c.ai = {
	model = "mistral:7b",
	system = "You are a senior developer in $LANG tasked with writing a docstring for the following funcion. The docstring should use best practices. Only write the docstring. Nothing else. do not write code. ",
	serve = true,
}
return c
