class Test:
    def __init__(self, name, lastname):
        self.name = name
        self.lastname = lastname

    def getname(self):
        return self.name
    
    def getlastname(self):
        return self.lastname
    
    def setname(self, name):
        if not isinstance(name, str):
            return "erreur, votre élément n'est pas un STR"
        self.name = name

    def setlastname(self, lastname):
        if not isinstance(lastname, str):
            return "erreur, votre élément n'est pas un STR"
        else:
            self.lastname = lastname
    
