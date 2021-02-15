[
.[] | {
	(.["Group/Project"]): { 
	"businessAdministrator": {
	   "name": .["businessAdministrator.name"],
	   "email": .["businessAdministrator.email"]
	},
	"accountNumber": .accountNumber,
	"fundingSourceName": .fundingSourceName,
	"fundingSourceExpirationDate": .fundingSourceExpirationDate,
	"iLabServiceRequestNumber": .iLabServiceRequestNumber,
	"PIs": (if .PIs == null then [] else (.PIs|split(", *";"g")) end )
	}
}
]