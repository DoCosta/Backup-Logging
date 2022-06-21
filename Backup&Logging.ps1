#########################################################################
#                                                                       #
#   Powershell                                                          #
#   Autor:     Dominik Costa                                            #
#   Datei:     Backup&Logging.ps1                                       #
#   Funktion:  Backup und Loggen                                        #
#   Version:   1.0                                                      #
#                                                                       #
#########################################################################

# Haupt Variablen Deklaration
$LogPfad = "\Test\logfile"                                 # <------ Log PFAD Ändern!    (Wo soll die Log Datei gespeichert werden?)
$AllgemeinerPfad  = "\Test\needed"                         # <------ Datei PFAD Ändern!  (Wo sind die zu bakupenden Files?)
$backupPfad = "\Test\bakup"                                # <------ Backup PFAD Ändern! (Wo sollen die Files gebakupdt werden?)
$Datum = get-date -Format "dd.MM.yyyy" 
$bedingung = 1
$AnzahlFiles1 = 0;


if (!(Test-Path ("$LogPfad\$Datum" + "_LogFile.txt"))){            
       # Erstellen des LogFiles            
       $Logfile = (New-Item ("$LogPfad\$Datum" + "_LogFile.txt") -ItemType File -Force).FullName   
        }else{            
        # Falls Logfile schon vorhanden, Datei in die Variabel $Logfile aufnehmen            
        $Logfile = (Get-Item ("$LogPfad\$Datum" + "_LogFile.txt")).FullName            
    } 
    
       
function Logersteller{               
       # Überschrift für das LogFile            
       Add-Content $Logfile ("Die LogDatei wurde erstellt am $(get-date -Format "dddd dd. MMMM yyyy HH:mm:ss") Uhr`n`n") 
       Add-Content $Logfile ""
       Add-Content $Logfile "Autor:     Dominik Costa"
       Add-Content $Logfile "Datei:     PraktischeArbeit.ps1"
       Add-Content $Logfile "Funktion:  Backup und Loggen"
       Add-Content $Logfile "Version:   1.0"
	   Add-Content $LogFile "Source:    $AllgemeinerPfad"
	   Add-Content $LogFile "Ziel:      $backupPfad"
       # Leerzeilen einfügen            
       Add-Content $Logfile "`n`n"            
       # Spaltenüberschrift generieren            
       $LogInhalt = ""            
       # Überschrift dem Logfile hinzufügen            
       Add-Content $Logfile $LogInhalt            
   }

function LogEintrag           
    {     
    
           
          
        param            
            (            
                [ValidateSet("INFO", "ERROR")]            
                [String]$Typ="INFO",            
                [ValidateNotNullOrEmpty()]            
                [String]$Text            
            )            
             
        if($LogFrage)
        { 
      
            # Generieren des Zeitstempels für die einzelnen LogZeilen            
            $TimeStamp = get-date -Format "[dd.MM.yyyy HH:mm:ss]"            
                    
            # Inhalt entsprechend Formatieren und zusammensetzen            
            $LogInhalt = "{0,-25}{1,-12}{2}" -f $TimeStamp,$Typ,$Text            
            
            # Hinzufügen zum LogFile            
            Add-Content $Logfile $LogInhalt 
        }else{
            Write-Host "."
        }
           
    }

     
##############################################################
#                                                            #
#     Wie man Log Einträge erstellt:                         #
# ---------------------------------------                    #
#                                                            #
# Infomeldung:                                               #
# LogEintrag -Typ INFO "eigener Info Text"                   #           
#                                                            #
# Errormeldung:                                              #
# LogEintrag -Typ ERROR "eigener Fehler Text"                #
#                                                            #
##############################################################


# ---------------------------------------------------------------------------------------------------
# Volles Bakup Funktion

function fullBackup
{
    
    #Info
    Add-Content $Logfile ""
    LogEintrag -Typ INFO "Bakup aller Dateien wird gemacht..." 
    $i = 1
    
    while ($i -le 3)
    {
        
        #Ordner werden geprüft
        if((Test-Path $AllgemeinerPfad\Ordner$i) -and !(Test-Path $backupPfad\Ordner$i))                                                              
        {
            # Ordner werden kopiert
            Copy-Item -Path $AllgemeinerPfad\Ordner$i -Destination $backupPfad -Recurse                                                               
            $Bool = 1
            Write-Host "----------------"
            Write-Host "Ordner$i"
            Write-Host "Backup erstellt!"
            Write-Host "----------------"           
        }
        $i++;       
    }
   
    if(!($Bool -eq 1)){LogEintrag -Typ ERROR "Backup aller Dateien konnten nicht erstellt werden. Nicht Verfügbare Dateien."  Write-Host "Fehlgeschlagen"  }
    else{
        $AnzahlFiles1 = Get-ChildItem $backupPfad -Recurse -File | Measure-Object | %{$_.Count}
        LogEintrag -Typ INFO "Backup von $AnzahlFiles1 Dateien müssen gemacht werden!" 
        $AnzahlFiles1 = Get-ChildItem $backupPfad -Recurse -File | Measure-Object | %{$_.Count}
        LogEintrag -Typ INFO "Backup aller Dateien wurde gemacht. $AnzahlFiles1 Files! " 
    }
    

}


# ---------------------------------------------------------------------------------------------------
# Funktion für die Filename such möglichkeit
function selectBackup
{
    # Filename
    $filename = Read-Host "Geben Sie den zu backupenden Filenamen an"
    #Info
    Add-Content $Logfile ""
    LogEintrag -Typ INFO "Backup aller Dateien mit dem Namen $filename, werden gemacht..." 
    #sucht alle Dateien und unterdateien des Pfades aus
    $pfad = Get-ChildItem -Path $AllgemeinerPfad -Depth 100 | Select-Object name 
    $b=1                                                                                
    foreach($i in $pfad)
    {     
        # Check ob irgentwo der Inhalt vorkommt  
        if($i -match $filename)
        {
            do{
              #Ordner werden geprüft
                if((Test-Path $AllgemeinerPfad\Ordner$b\$filename.*) -and !(Test-Path $backupPfad\Ordner$b))                                     
                {
                
                   # Ordner werden kopiert
                   Copy-Item -Path $AllgemeinerPfad\Ordner$b\$filename.* -Destination $backupPfad -Recurse                                      
                   
                   $Bool = 1
                   Write-Host "----------------"
                   Write-Host "$i"
                   Write-Host "Backup erstellt!"
                   Write-Host "----------------"
                 }
                $b++;
                }while($b -le 5)
          }
    }
    # Log eintrag bei Fehler
    if(!($Bool -eq 1)){LogEintrag -Typ ERROR "Backup aller Dateien mit dem Namen $filename, konnten nicht erstellt werden. Nicht Verfügbare Dateien.";  Write-Host "Fehlgeschlagen"  }
    else{
        $AnzahlFiles1 = Get-ChildItem $backupPfad -Recurse -File | Measure-Object | %{$_.Count}
        LogEintrag -Typ INFO "Backup von $AnzahlFiles1 Dateien müssen gemacht werden!" 
        $AnzahlFiles1++;
        LogEintrag -Typ INFO "Backup aller Dateien wurde gemacht. $AnzahlFiles1 Files! " 
    }
}


# ---------------------------------------------------------------------------------------------------
# Funktion für die Inhalt such möglichkeit

function selectBackupinhalt
{
    # gesuchter Fileinhalt
    $suchstring = Read-Host "Geben Sie den Inhalt ein"


    #Info
    Add-Content $Logfile ""
    LogEintrag -Typ INFO "Backup aller Dateien mit dem Inhalt $suchstring, werden gemacht..." 

    $pfad = Get-ChildItem -Path $AllgemeinerPfad\Ordner* -Depth 100 | Select-Object name                                                     


    foreach($i in $pfad)
    {
        $b=1;
        $c = $i
          if($i -match ".*txt")
          {
            $i = $i -replace ".*=" -replace ".txt.*"  
          }
          

         while ($b -le 3)
            { 
            $Pfad= "$AllgemeinerPfad\Ordner$b\$i*"                                                                                              

            if((Test-Path $Pfad) -and !(Test-Path $backupPfad\Ordner$b))                                                                                
                {
                     $inhalt = Get-Content -Path $Pfad
                 }
            if($inhalt -match $suchstring)
            {
            
                #Ordner werden geprüft
                if((Test-Path $AllgemeinerPfad\Ordner$b\$i*) -and !(Test-Path $backupPfad\Ordner$b))                            
                {
                
                   # Ordner werden kopiert
                   Copy-Item -Path $Pfad -Destination $backupPfad                                                                                        
                   
                   $Bool = 1
                   Write-Host "----------------"
                   Write-Host "$i"
                   Write-Host "Backup erstellt!"
                   Write-Host "----------------"
                   $AnzahlFiles1++;
                }
                
            }
            
            $b++;            
        }
      
    }
    # Log eintrag bei Fehler    
    if(!($Bool -eq 1)){LogEintrag -Typ ERROR "Backup aller Dateien mit dem Inhalt $suchstring, konnten nicht erstellt werden. Nicht Verfügbare Dateien."; Write-Host "Fehlgeschlagen" }
    else{
        $AnzahlFiles1 = Get-ChildItem $backupPfad -Recurse -File | Measure-Object | %{$_.Count}
        LogEintrag -Typ INFO "Backup von $AnzahlFiles1 Dateien müssen gemacht werden!" 
        
        LogEintrag -Typ INFO "Backup aller Dateien wurde gemacht. $AnzahlFiles1 Files! " 
    }
}


# ---------------------------------------------------------------------------------------------------
# Funktion für die Fileende such möglichkeit

function selectBackupfileend
{
    # gesuchte Dateiendung
    $filename = Read-Host "Geben Sie das zu Backupende Fileende an"


    #Info
    Add-Content $Logfile ""
    LogEintrag -Typ INFO "Backup aller Dateien mit der Endung $filename, werden gemacht..." 

    $pfad = Get-ChildItem -Path $AllgemeinerPfad -Depth 100 | Select-Object name                                                              

    $b=1 

    foreach($i in $pfad)
    {
        
           
        if($i -match $filename)
        {

         
                
                #Ordner werden geprüft
                if((Test-Path $AllgemeinerPfad\Ordner$b\*.$filename) -and !(Test-Path $backupPfad\Ordner$b))                                          
                {
                    
                   # Ordner werden kopiert
                   Copy-Item -Path $AllgemeinerPfad\Ordner$b\*.$filename -Destination $backupPfad -Recurse                                              
                  
                   $Bool = 1
                   Write-Host "----------------"
                   Write-Host "$i"
                   Write-Host "Backup erstellt!"
                   Write-Host "----------------"
                   $AnzahlFiles1++;
                }
                $b++;
            
            
        }
      
    }
    # Log eintrag bei Fehler    
    if(!($Bool -eq 1)){LogEintrag -Typ ERROR "Backup aller Dateien mit der Endung $filename, konnten nicht erstellt werden. Nicht Verfügbare Dateien.";  Write-Host "Fehlgeschlagen"  }
    else{
         $AnzahlFiles1 = Get-ChildItem $backupPfad -Recurse -File | Measure-Object | %{$_.Count}
        LogEintrag -Typ INFO "Backup von $AnzahlFiles1 Dateien müssen gemacht werden!" 
        LogEintrag -Typ INFO "Backup aller Dateien wurde gemacht. $AnzahlFiles1 Files! " 
    }
}

# ---------------------------------------------------------------------------------------------------
# Abfrage des Users

function Abfrage
{
    do{

        # Abfrage: soll geloggt werden?
		$LogFrage = Read-Host "Sollem die Dateien geloggt werden? ja/nein"
		if ($LogFrage -eq "ja" -or $LogFrage -eq "Ja")
		{
			Write-Host "Es wird ein Log erstellt!"
            $LogFrage = $TRUE;
            Logersteller

		}elseif ($LogFrage -eq "nein" -or $LogFrage -eq "Nein")
		{
			Write-Host "Es wird kein Log erstellt!"
            $LogFrage = $FALSE;
		}else
		{
			Write-Host "Falsche Eingabe! Es wird kein Log erstellt!"
            $LogFrage = $FALSE;		
            }
        # Abfrage, welche form des Backups der User verwenden will.
       $Antwort = Read-Host "Wollen Sie ein Volles Backup (vb) oder ein Seklektives Backup (sb) erstellen"

       if ($Antwort-eq "sb")
       {
            # Abfrage, welche form des selektivem Backups der User verwenden will.
            $Antwort = Read-Host "Wollend Sie die Endung(endung), den Inhalt(inhalt) oder den Namen(name) der Datei eingeben?"

            if($Antwort -eq "endung"){
                $bedingung = 2
                # Funktionsaufruf
                selectBackupfileend
            }
            elseif($Antwort -eq "name"){
                $bedingung = 2
                # Funktionsaufruf
                selectBackup
            }elseif($Antwort -eq "inhalt"){
                $bedingung = 2
                # Funktionsaufruf
                selectBackupinhalt
            }else{
                Write-Host "Falsche Eingabe!"
            }
     
       }
       # Check Volles Backup mit allen unterdateien.
       elseif ($Antwort -eq "vb")
           {
                $bedingung = 2
                # Funktionsaufruf
                 fullBackup
            
           }
           else
           {
             Write-Host "Falsche Eingabe!"
           }
        
     }while($bedingung -eq 1)  
}

# ---------------------------------------------------------------------------------------------------
# Funktionsaufruf

Abfrage

 # Erstellen des 2. LogFiles            
 
$KopierteFiles = (New-Item ("$LogPfad\kopierte Files") -ItemType File -Force).FullName   

Add-Content $KopierteFiles (Get-ChildItem -Path $backupPfad -Depth 100 | Select-Object name)


           
      
        
