# Powershell_class_setters
Example to implement Class property Set and Get in Powershell.

Until now, Powershell 5, 6 and Core 7, the implementation of classes in Powershell does not natively include the possibility of creating Set and Get methods for properties. This is a pity in particular for the Set function of a property which allows to have a unique location for the property validation code inside the class.

I found this solution in the answer from "alx9r" in Stackoverflow here:
https://stackoverflow.com/questions/39717230/powershell-class-implement-get-set-property/40365941#40365941
