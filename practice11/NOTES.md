# Practice 11

## Run

Open a terminal in `practice11`, then run `flutter pub get` and `flutter run`.

## Level 1 — Real JSON

The requests were checked with curl. GET /users returned 200 and 10 users.
GET /users/1 returned one user object. The Content-Type was
`application/json; charset=utf-8`.

| Request | Status | Body |
| --- | --- | --- |
| GET /users | 200 | A list of 10 users |
| GET /users/1 | 200 | One user object |
| GET /users/999 | 404 | `{}` |
| GET /users?id=3 | 200 | A list with one user, id 3 |
| POST /users | 201 | The sent fields with id 11 |

### User fields

| Field | JSON type | Dart type | Nullable |
| --- | --- | --- | --- |
| id | number | int | No |
| name | string | String | No |
| username | string | String | No |
| email | string | String | No |
| address | object | Address | No |
| phone | string | String | No |
| website | string | String? | Yes, by the task |
| company | object | Named record | No |

### Address fields

| Field | JSON type | Dart type | Nullable |
| --- | --- | --- | --- |
| street | string | String | No |
| suite | string | String | No |
| city | string | String | No |
| zipcode | string | String | No |
| geo | object | Geo | No |

### Geo fields

| Field | JSON type | Dart type | Nullable |
| --- | --- | --- | --- |
| lat | string | double | No |
| lng | string | double | No |

### Company fields

| Field | JSON type | Dart type | Nullable |
| --- | --- | --- | --- |
| name | string | String | No |
| catchPhrase | string | String | No |
| bs | string | String | No |

Address and company are nested objects. Geo is inside address, so it is
nested twice. The inspected user 1 had every field and no null values.
The task makes website optional, so the model also accepts a missing
website or `null`. The company record includes `bs` to preserve the full
response when converting it back to JSON.

## Level 2 — Model checks

The real user 1 parsed as Leanne Graham. Converting the model to JSON and
back preserved the nested values. Website passed the same check with a
value, with null and with the key removed. Phone digits became
`1770736803156442`; the original phone text stayed unchanged.

The two deliberate wrong casts produced these messages:

```text
type 'String' is not a subtype of type 'double' in type cast
type 'String' is not a subtype of type 'int' in type cast
```

Latitude and longitude use `double.parse` because the API sends strings.

## Level 3 — Repository checks

A live repository run printed all 10 names, caught `NotFoundException`
for user 999, and created a full draft with returned id 11.

Controlled responses checked GET and POST errors before JSON parsing.
401 became UnauthorizedException, 404 became NotFoundException, and
500, 503 and 599 became ServerException with the status.
Other unexpected statuses became BadResponseException.
Malformed JSON, a string id, an invalid latitude and missing required
objects also became BadResponseException.

When 404 checking was deliberately bypassed in a temporary copy, the empty
body object reached the model and produced:

```text
/users/999: type 'Null' is not a subtype of type 'Map<String, dynamic>' in type cast
```

The model reads company first. This error hid the real cause, a missing
user. The normal code checks the HTTP status first.

SocketException, TimeoutException and http.ClientException all became
NoConnectionException in controlled tests. A response that never arrived
timed out at 10 seconds of test-clock time.

`UserRepository.network()` creates the HTTP client. This keeps the HTTP
imports in api_client.dart and user_repository.dart while main.dart wires
the repository and model together.

## Level 4 — Screen and model checks

Removing the BadResponseException case in a temporary copy caused this
analyzer error:

```text
The type 'ApiException?' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'BadResponseException()'.
```

The model prevents duplicate loads and overlapping load/save requests.
Tests also completed requests after disposing the model without sending
late notifications.

## Level 5 — Save and connection checks

Widget tests checked empty names, empty usernames and invalid email
addresses. A double tap started one POST in the test. Save was disabled
while waiting, and the returned id 11 was added at the top of the list.
500, bad JSON and connection errors kept the form open with a SnackBar.
Retrying Save then succeeded. Leaving during Save caused no extra
navigation or SnackBar on the previous screen.

The three-field form sends empty phone, address and company text, null
website, and zero coordinates for the fields it does not collect.
JSONPlaceholder simulates writes. Refreshing the list removes the locally
added user.

The temporary test suite passed 36 checks of the model, repository and
form. The network timings and DevTools captures are recorded below.

| Connection check | Time to Offline | Observation |
| --- | --- | --- |
| Android emulator, airplane mode on and Wi-Fi off | 4.305 s | NoConnectionException after a failed DNS lookup |
| Windows native Flutter test, local proxy holding the connection | 10.177 s | NoConnectionException with the ten-second timeout enabled |

The airplane-mode check used an Android API 36.1 emulator. Its DNS failure
took about four seconds. This run exceeded the one-second target in the
task.

The timeout check used the actual ApiClient, UsersModel and HTTP client in
a native Flutter test on Windows. A local proxy accepted the CONNECT
request, held it for about ten seconds, then closed the socket.
DevTools recorded GET /users with no HTTP status and a duration of
10.405 seconds. The model showed Offline before the network row closed.
After removing the proxy delay, the same client loaded 10 users in
0.776 seconds and cleared the error.
A physical phone connected to a hotspot without internet was not tested.

The successful 200 request was captured separately on the Android
emulator using JSONPlaceholder in `screenshot_200.png`.
`screenshot_timeout.png` shows the Windows test request in DevTools.
Its Status cell says Error and there is no HTTP response code.

## Final checks

- `dart format .` completed and `flutter analyze` reported no issues.
- The Android debug APK and the web build both completed.
- The live repository POST and the form widget tests passed separately.
  The full Android form flow was not manually tested.
