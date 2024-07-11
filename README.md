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
* **Content:** It renders all users with their IDs, usernames, first names, last names, and birthdays in a JSON format:
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
* **Code:** 401 Unauthorized (returned if the user is not authenticated)
* **Content:** It renders the following error:
```json
{
  "errors": ["You need to sign in or sign up before continuing."]
}
```

## Posts Index Endpoint

### Endpoint
`GET /api/v1/users/:user_id/posts`

### Description
Returns all posts of a given user. This endpoint is accessible only to authenticated users.

### Request
* **URL:** `/api/v1/users/:user_id/posts`
* **Method:** `GET`
* **Headers:**
  * `Content-Type: application/json`
  * `Accept: application/json`
  * `access-token: <ACCESS_TOKEN>`
  * `client: <CLIENT>`
  * `uid: <UID>`
* **Authentication Required:** Yes

### Parameters
* `user_id` (path parameter): The ID of the user whose posts are to be returned.

### Response
#### Success Response
* **Code:** 200 OK
* **Content:** It renders the user's posts with their IDs, titles, bodies, publishing dates, user's IDs, like counts, and comment counts in a JSON format:
```json
[
    {
        "id": 1,
        "title": "Post1",
        "body": "Post Content",
        "published_at": "2024-06-26T19:30:28.945Z",
        "user_id": 1,
        "likes_count": 5,
        "comments_count": 0
    },
    {
        "id": 2,
        "title": "Post2",
        "body": "Post Content",
        "published_at": "2024-06-26T19:30:28.945Z",
        "user_id": 1,
        "likes_count": 8,
        "comments_count": 3
    }
]
```

#### Error Responses
* **Code:** 401 Unauthorized (returned if the user is not authenticated)
* **Content:** It renders the following error:
```json
{
  "errors": ["You need to sign in or sign up before continuing."]
}
```

* **Code:** 404 Not Found (returned if the user does not exist)
* **Content:** It renders the following error:
```json
{
    "error": "User not found."
}
```
