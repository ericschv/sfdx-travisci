{
  "endorsements": [
    {
      "id": "12345",
      "createdAt": "2020-01-18",
      "updatedAt": "2020-01-18",
      "endorsementType": "updateCoverage",
      "effectiveDate": "2020-01-25",
      "newTotalPremium": "1100",
      "oldTotalPremium": "1000",
      "premiumDelta": "100",
      "proratedPremium": "1100",
      "events": [
        {
          "id": "1",
          "type": "updateCoverage",
          "recordType": "coverage",
          "recordId": "123454",
          "recordName": "My Coverage",
          "oldValue": "0",
          "newValue": "101"
        },
        {
          "id": "2",
          "type": "updateCoverage",
          "recordType": "coverage",
          "recordId": "123454",
          "recordName": "My Coverage",
          "oldValue": "101",
          "newValue": "100"
        }
      ],
      "policyId": "testPolicyId1234",
      "userId": "1234234",
      "notes": "Oh yeah this is my endorsement"
    },
    {
      "id": "12346",
      "createdAt": "2020-01-19",
      "updatedAt": "2020-01-19",
      "endorsementType": "updateCoverage",
      "effectiveDate": "2020-01-25",
      "newTotalPremium": "1050",
      "oldTotalPremium": "1100",
      "premiumDelta": "50",
      "proratedPremium": "1200",
      "events": [
        {
          "id": "3",
          "type": "updateCoverage",
          "recordType": "coverage",
          "recordId": "123455",
          "recordName": "My Second Coverage",
          "oldValue": "100",
          "newValue": "40"
        },
        {
          "id": "4",
          "type": "updateCoverage",
          "recordType": "coverage",
          "recordId": "123455",
          "recordName": "My Second Coverage",
          "oldValue": "40",
          "newValue": "50"
        }
      ],
      "policyId": "testPolicyId1234",
      "userId": "1234234",
      "notes": "Oh yeah this is my second endorsement"
    },
    {
      "id": "12346",
      "createdAt": "2020-01-20",
      "updatedAt": "2020-01-20",
      "endorsementType": "updateCoverage",
      "effectiveDate": "2020-01-25",
      "newTotalPremium": "1200",
      "oldTotalPremium": "1050",
      "premiumDelta": "88",
      "proratedPremium": "1200",
      "events": [
        {
          "id": "5",
          "type": "createCoverage",
          "recordType": "coverage",
          "recordId": "123456",
          "recordName": "My Third Coverage",
          "oldValue": "0",
          "newValue": "150"
        }
      ],
      "policyId": "testPolicyId1234",
      "userId": "1234234",
      "notes": "Oh yeah this is my third endorsement"
    }
  ]
}