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

## Get Post Details Endpoint

### Endpoint
`GET /api/v1/posts/:id`

### Description
Returns the details of a post. This endpoint is accessible only to authenticated users.

### Request
* **URL:** `/api/v1/posts/:id`
* **Method:** `GET`
  * `Content-Type: application/json`
  * `Accept: application/json`
  * `access-token: <ACCESS_TOKEN>`
  * `client: <CLIENT>`
  * `uid: <UID>`
* **Authentication Required:** Yes

### Parameters
* `id` (path parameter): The ID of the post to retrieve details for.

### Response
#### Success Response
* **Code:** 200 OK
* **Content:** It renders the post with its ID, title, body, publishing date, user's ID, likes, and comments (including their replies), in a JSON format:
```json
{
    "id": 1,
    "title": "Post Title",
    "body": "Post Body",
    "published_at": "2024-06-28T17:09:37.798Z",
    "user_id": 1,
    "likes": [
        {
            "user_id": 2,
            "nickname": "user2"
        }
    ],
    "comments": [
        {
            "id": 1,
            "content": "One Comment",
            "replies": [
                {
                    "id": 2,
                    "content": "Reply to the comment"
                }
            ]
        },
        {
            "id": 3,
            "content": "Another Comment",
            "replies": []
        }
    ]
}
```

#### Error Responses
* **Code:** 401 Unauthorized (returned if the user is not authenticated)
* **Content:** It renders the following error:
```json
{
  "errors": ["You need to sign in or sign up before continuing."]
}
```

* **Code:** 404 Not Found (returned if the post does not exist)
* **Content:** It renders the following error:
```json
{
    "error": "Post not found."
}
```

## Create a Post Endpoint

### Endpoint
`POST /api/v1/users/:user_id/posts`

### Description
Creates a new post for a given user. This endpoint is accessible only to authenticated users.

### Request
* **URL:** `/api/v1/users/:user_id/posts`
* **Method:** `POST`
* **Headers:**
  * `Content-Type: application/json`
  * `Accept: application/json`
  * `access-token: <ACCESS_TOKEN>`
  * `client: <CLIENT>`
  * `uid: <UID>`
* **Authentication Required:** Yes

### Parameters
* `user_id` (path parameter): The ID of the user for whom the post will be created.

### Response
#### Success Response
* **Code:** 200 OK
* **Content:** It renders the new post data including its ID, title, body, publishing date, user ID, likes count and comment counts in a JSON format:
```json
{
    "id": 1,
    "title": "New Post Title",
    "body": "New Post Body",
    "published_at": "2024-07-12T19:04:14.671Z",
    "user_id": 1,
    "likes_count": 0,
    "comments_count": 0
}
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

* **Code:** 422 Unprocessable Content (returned if any validation fails)
* **Content:** It renders the following errors:

```json
{
    "errors": [
        "Title can't be blank",
        "Body can't be blank"
    ]
}
```

* **Code:** 403 Forbidden (returned when attempting to create a post for another user)
* **Content:** It renders the following error:

```json
{
    "errors": [
        "You can only create a post for yourself."
    ]
}
```

## Edit Post Endpoint

### Endpoint
`PUT /api/v1/posts/:id`

`PATCH /api/v1/posts/:id`

### Description
Updates a post's title and content. This endpoint is accessible only to authenticated users.

### Request
* **URL:** `/api/v1/posts/:id`
* **Methods:** `PUT` and `PATCH`
* **Headers:**
  * `Content-Type: application/json`
  * `Accept: application/json`
  * `access-token: <ACCESS_TOKEN>`
  * `client: <CLIENT>`
  * `uid: <UID>`
* **Authentication Required:** Yes

### Parameters
* `id` (path parameter): The ID of the post to be updated.

### Response
#### Success Response
* **Code:** 200 OK
* **Content:** It renders the updated post info including its ID, title, body, publishing date, user ID, like count, and comment count in a JSON format:
```json
{
    "id": 1,
    "title": "Edited Title",
    "body": "Edited Body",
    "published_at": "2024-06-26T19:30:28.945Z",
    "user_id": 1,
    "likes_count": 5,
    "comments_count": 0
}
```

#### Error Responses
* **Code:** 401 Unauthorized (returned if the user is not authenticated)
* **Content:** It renders the following error:
```json
{
  "errors": ["You need to sign in or sign up before continuing."]
}
```

* **Code:** 404 Not Found (returned if the post does not exist)
* **Content:** It renders the following error:
```json
{
    "error": "Post not found."
}
```
**Code:** 403 Forbidden (returned if the post does not belong to de logged user)
* **Content:** It renders the following error:

```json
{
    "errors": [
        "You are not authorized to update this post."
    ]
}
```
