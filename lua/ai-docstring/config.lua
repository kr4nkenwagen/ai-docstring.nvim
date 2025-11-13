local c = {}
c.key = "<leader>od"
c.accept_key = "<leader>"
c.decline_key = "q"
c.renew_key = "r"
c.ai = {
	model = "mistral:7b",
	prompt = "Fill in the template with information from the $LANG function at the end. do not write code. Write only the template. with data. Nothing else: $TEMPLATE \n\n$FUNC",
	serve = true,
}
return c
