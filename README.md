# README

## Users Index Endpoint

### Endpoint
`GET /api/v1/users`

### Description
Returns a list of all users. This endpoint is accessible only to authenticated users.

### Request
* **URL:** `/api/v1/users`
* **Method:** `GET`
* **Headers:**
  * `Content-Type: application/json`
  * `Accept: application/json`
  * `access-token: <ACCESS_TOKEN>`
  * `client: <CLIENT>`
  * `uid: <UID>`
* **Authentication Required:** Yes

### Parameters
This endpoint does not require any parameters.

### Response
#### Success Response
* **Code:** 200 OK
* **Content:** It renders all users with their id’s, usernames, first names, last names and birthdays in a JSON format:
```json
[
    {
        "id": 1,
        "email": "user1@example.com",
        "nickname": "user1",
        "first_name": "User",
        "last_name": "One",
        "birthday": "2001-08-07"
    },
    {
        "id": 2,
        "email": "user2@example.com",
        "nickname": "user2",
        "first_name": "User",
        "last_name": "Two",
        "birthday": "1995-01-19"
    }
]
```

#### Error Response
* **Code:** 401 Unauthorized
* **Content:** It renders the following error:
```json
{
  "errors": ["You need to sign in or sign up before continuing."]
}
```
