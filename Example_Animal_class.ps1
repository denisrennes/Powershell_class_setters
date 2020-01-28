[CmdletBinding()]
param (  
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'


# $NL = New Line constant: 0x0D0A for Windows platform, 0x0A for Unix
$NL = [Environment]::NewLine

class Animal
{
    [string] $Name

    # This is the example for a Get and Set methods of the "Nb_Legs" property
   	# Never use "_Nb_Legs"! It is a hidden property that allows to create the actual 'Language' property with Get and Set accessors
    # Unique location, inside the class definition, of the code required to validate and set a value to the "NB_Legs" property, or get its value.
    # Found this tip in the answer from "alx9r" in Stackoverflow here: https://stackoverflow.com/questions/39717230/powershell-class-implement-get-set-property/40365941#40365941
    hidden [int] $_Nb_Legs = $($this | Add-Member ScriptProperty 'Nb_Legs' `
        {
            # get
            [int]($this._Nb_Legs)
        }`
        {
            # set
            # Will throw an exception if the value is rejected
            param ( $nb_legs_arg )
            try {
                try { [int]$nb_legs = [int]$nb_legs_arg }
                catch { 
                    throw ('"NB_Legs" must be an integer: "{1}" is incorrect' -f $this.Name, $nb_legs_arg )
                }
                if ( ($nb_legs -lt 0) -or ($nb_legs -gt 750 ) ) {
                    throw ('"NB_Legs" must be between 0 and 750: "{0}" is incorrect' -f $nb_legs_arg )
                }
                if ( ($nb_legs % 2) -ne 0 ) {
                    throw ('"NB_Legs" must be even: "{0}" is incorrect' -f $nb_legs_arg )
                }
                $this._Nb_Legs = [int]$nb_Legs
            }
            catch {
                Write-Verbose ( 'Cannot set "Nb_Legs" for "{0}": {1}' -f $this.Name, $_ )
                throw
            }
        }
    )

    # Constructor with 2 arguments: name and number of legs
    Animal( [string] $name, [int] $nb_legs )
    {
        try { 
            $this.Name = $name
            $this.Nb_Legs = $nb_legs
            Write-Verbose ( 'Animal("{0},{1}") is accepted' -f $this.Name, $this.Nb_Legs ) 
         }
        catch { 
            # rejected by property setters
            $message = 'Animal("{0}",{1}) is rejected: {2}' -f $name, $nb_legs, $_
            write-verbose $message
            throw $message
        }   
    }

    # Constructor with 1 argument like "cat: 4", a string with 2 fields separated with ':'. The 1st field is the animal name, the 2nd field is its number of legs
    Animal( [string] $name_eq_nblegs )
    {
        $fields = $name_eq_nblegs -split ':'
        if ( $fields.Count -ne 2 ) { 
            # rejected by the constructor argument parser
            $message = 'Animal("{0}") is rejected: it does not contain 2 fields separated with ''=''' -f $name_eq_nblegs
            Write-Verbose $message
            throw $message
        }
        
        try { 
            $this.Name = $fields[0].Trim()
            $this.Nb_Legs = $fields[1].Trim()
            Write-Verbose ( 'Animal("{0}") is accepted' -f $name_eq_nblegs )   
        }
        catch { 
            # rejected by property setters
            $message = 'Animal("{0}") is rejected: {1}' -f $name_eq_nblegs, $_
            write-verbose $message
            throw $message
        }
    }

    # Constructor without argument (default construction): required for the Clone() optimized method
    # Should not be used outside the class: it could lead to non-valid animal objects with some empty properties
    hidden Animal( )
    {
    }

    # Object cloning: avoids side effects when two variables contain the same object
    # This is the optimized version: it does not call the property accessors but it requires the default constructor without any parameter
    [Animal]Clone() {
        $cloned = [Animal]::New()
        $cloned.Name = $this.Name
        $cloned._Nb_Legs = $this._Nb_Legs
        return $cloned
	}


    # ToString() method is very commonly required. Examples here: 'cat: 4', 'millepede: 750'
	[string]ToString() {
		$result = $this.Name
		if ( $this.Quality -ne 1 ) {
			$result += ': ' + $this.Nb_Legs
		}
		return $result
	}
}

$animal_list_input = @('Cat:4', 'Millepede: 1000', 'Spider:8', 'human:four' )

$animal_list = $animal_list_input | Foreach-Object { try { [Animal]::New($_) } catch { } }

write-verbose ( '{0} animals were accepted' -f $animal_list.Count )

$animal_list +=  try{ [Animal]::New('Dog', 4) } catch{}
$animal_list +=  try{ [Animal]::New('Ant: 6') } catch{}
$animal_list +=  try{ [Animal]::New('kangaroo:3') } catch {}

write-verbose ( '{0} animals were accepted' -f $animal_list.Count )

try { $animal_list[0].Nb_Legs = 3333 } catch {}
write-verbose ( 'The animal "{0}" has {1} legs!' -f $animal_list[0].Name, $animal_list[0].Nb_Legs )


$animal_list2 = @( $animal_list | % { $_.Clone() } )
try { $animal_list2[0].Nb_Legs = 42 } catch {}

write-verbose ( 'animal_list:' + (($animal_list | ft -auto ) | Out-String).TrimEnd($NL) )
write-verbose ( 'animal_list2:' + (($animal_list2 | ft -auto ) | Out-String).TrimEnd($NL) )
