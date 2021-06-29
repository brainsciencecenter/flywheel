[ .[] | keys[0] as $Key | .[]
| (if . == null then
  {
    "Group": ($Key | split("/"))[0],
    "Project": ($Key | split("/"))[1],
    "businessAdministrator.name": null,
    "businessAdministrator.email": null,

    "accountNumber": null,
    "fundingSourceName": null,
    "fundingSourceExpirationDate": null,
    "iLabServiceNumber": null,
    "PIs": null
  }
else 
  {
    "Group": ($Key | split("/"))[0],
    "Project": ($Key | split("/"))[1],
    "businessAdministrator.name": .businessAdministrator.name,
    "businessAdministrator.email": .businessAdministrator.email,

    "accountNumber": .accountNumber,
    "fundingSourceName": .fundingSourceName,
    "fundingSourceExpirationDate": .fundingSourceExpirationDate,
    "iLabServiceRequestNumber": .iLabServiceRequestNumber,
    "PIs": ( if .PIs == null then "" else .PIs|join(", ") end )
  }
end  
)] | ( .[0] | to_entries | map(.key)), (.[] | [.[]]) | @csv