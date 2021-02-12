[
.[] | {
	(.["Group/Project"]): { 
	"businessAdministrator": {
	   "name": .["businessAdministrator.name"],
	   "email": .["businessAdministrator.email"]
	},
	"accountNumber": .accountNumber,
	"fundingSourceName": .fundingSourceName,
	"iLabServiceNumber": .iLabServiceNumber,
	"PIs": (if .PIs == null then [] else (.PIs|split(", *";"g")) end )
	}
}
]