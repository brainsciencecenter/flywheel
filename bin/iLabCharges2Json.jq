{
  "1234": [ 
	.ilab_response.charges[] |
		  .quantity as $Quantity
		| .name as $Name
		| .status as $Status
		| .billing_status as $BillingStatus
		| .cost_allocations[0]
		| {
		     "Cost"		: $Quantity,
		     "ChargeName"	: $Name,
		     "Status"		: $Status,
		     "BillingStatus"	: $BillingStatus,
		     "Created"	    	: .payment_number.created_at,
		     "FundExpiration"  	: .payment_number.expires_at,
		     "FundNumber"	: (.payment_number | "\(.n1)-\(.n2)-\(.n3)-\(.n4)-\(.n5)-\(.n6)-\(.n7)-\(.n8)"),
		     "FundDescription" 	: .payment_number.description 
		  }
]
}