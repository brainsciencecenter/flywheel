  keys[0] as $Key | .[] 
| if . == null
then
  [ $Key, null, null, null, null, null, null ]
else
  [ 
    ($Key | split("/"))[],
    .businessAdministrator.name,
    .businessAdministrator.email,
    .accountNumber,
    .fundingSourceName,
    .iLabServiceRequestNumber,
     if .PIs == null 
     then
	empty
     else
	.PIs|join(", ") 
     end 
  ]
end
| @csv

