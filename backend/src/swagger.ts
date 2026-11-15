export const swaggerSpec = {
  openapi: "3.0.0",
  info: {
    title: "Entourage API",
    version: "1.0.0",
    description: "Backend API for the Entourage iOS app",
  },
  servers: [{ url: "/api/v1" }],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: "http",
        scheme: "bearer",
        description: "Pass the user's authentication_token",
      },
    },
    schemas: {
      Meta: {
        type: "object",
        properties: {
          code: { type: "integer", example: 200 },
          message: { type: "string", example: "Success" },
        },
      },
      User: {
        type: "object",
        properties: {
          id: { type: "integer" },
          phone_number: { type: "string", nullable: true },
          authentication_token: { type: "string", nullable: true },
          first_name: { type: "string", nullable: true },
          last_name: { type: "string", nullable: true },
          user_name: { type: "string", nullable: true },
          bio: { type: "string", nullable: true },
          gender: { type: "string", nullable: true, enum: ["male", "female"] },
          dob: { type: "integer", nullable: true },
          age: { type: "integer", nullable: true },
          latitude: { type: "string", nullable: true },
          longitude: { type: "string", nullable: true },
          city: { type: "string", nullable: true },
          state: { type: "string", nullable: true },
          is_blocked: { type: "boolean" },
          is_banned: { type: "boolean" },
          photos: { type: "array", items: { $ref: "#/components/schemas/Photo" } },
          fcm_tokens: { type: "array", items: { type: "string" } },
        },
      },
      Photo: {
        type: "object",
        properties: {
          id: { type: "integer" },
          user_id: { type: "integer" },
          original: { type: "string" },
          medium: { type: "string" },
          thumb: { type: "string" },
          is_primary: { type: "boolean" },
          order: { type: "integer" },
        },
      },
      Setting: {
        type: "object",
        properties: {
          id: { type: "integer" },
          user_id: { type: "integer" },
          everyone: { type: "boolean" },
          male_only: { type: "boolean" },
          female_only: { type: "boolean" },
          min_age: { type: "integer" },
          max_age: { type: "integer" },
          max_distace: { type: "integer" },
          group_member_count: { type: "integer" },
          block_member_count: { type: "integer" },
          general: { type: "boolean" },
          friendship: { type: "boolean" },
          match: { type: "boolean" },
          group: { type: "boolean" },
          chat: { type: "boolean" },
        },
      },
      Group: {
        type: "object",
        properties: {
          id: { type: "integer" },
          status: { type: "string", enum: ["active", "in_active"] },
          name: { type: "string", nullable: true },
          city: { type: "string", nullable: true },
          state: { type: "string", nullable: true },
          distance: { type: "string", nullable: true },
          users: { type: "array", items: { $ref: "#/components/schemas/User" } },
        },
      },
      Match: {
        type: "object",
        properties: {
          id: { type: "integer" },
          status: { type: "string", enum: ["active", "unmatched"] },
          distance: { type: "number", nullable: true },
          chat_id: { type: "integer" },
          matcher: { $ref: "#/components/schemas/Group" },
        },
      },
    },
  },
  paths: {
    "/users/check_ios_version": {
      get: {
        tags: ["Users"],
        summary: "Check iOS version validity",
        parameters: [{ in: "query", name: "ios_version", required: true, schema: { type: "string" } }],
        responses: {
          200: { description: "OK", content: { "application/json": { schema: { type: "object", properties: { meta: { $ref: "#/components/schemas/Meta" }, data: { type: "object", properties: { is_valid: { type: "boolean" } } } } } } } },
        },
      },
    },
    "/users/user_signup": {
      post: {
        tags: ["Users"],
        summary: "Sign up / log in by phone number",
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["phone_number"], properties: { phone_number: { type: "string", example: "+14155551234" } } } } } },
        responses: {
          200: { description: "User created or updated", content: { "application/json": { schema: { type: "object", properties: { meta: { $ref: "#/components/schemas/Meta" }, data: { $ref: "#/components/schemas/User" } } } } } },
        },
      },
    },
    "/users/user_by_auth_token": {
      get: {
        tags: ["Users"],
        summary: "Get current user by auth token",
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: "OK", content: { "application/json": { schema: { type: "object", properties: { meta: { $ref: "#/components/schemas/Meta" }, data: { $ref: "#/components/schemas/User" } } } } } },
        },
      },
    },
    "/users/user_by_phone_number": {
      get: {
        tags: ["Users"],
        summary: "Get user by phone number",
        parameters: [{ in: "query", name: "phone_number", required: true, schema: { type: "string" } }],
        responses: {
          200: { description: "OK", content: { "application/json": { schema: { type: "object", properties: { meta: { $ref: "#/components/schemas/Meta" }, data: { $ref: "#/components/schemas/User" } } } } } },
        },
      },
    },
    "/users/edit_profile": {
      post: {
        tags: ["Users"],
        summary: "Edit user profile",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", properties: { gender: { type: "string", enum: ["male", "female"] }, first_name: { type: "string" }, last_name: { type: "string" }, user_name: { type: "string" }, bio: { type: "string" }, dob: { type: "integer", description: "Unix timestamp in seconds" } } } } } },
        responses: { 200: { description: "Updated user" } },
      },
    },
    "/users/user_name_available": {
      get: {
        tags: ["Users"],
        summary: "Check username availability",
        parameters: [{ in: "query", name: "user_name", required: true, schema: { type: "string" } }],
        responses: {
          200: { description: "Available" },
          422: { description: "Username taken" },
        },
      },
    },
    "/users/delete_account": {
      delete: {
        tags: ["Users"],
        summary: "Soft-delete account",
        security: [{ bearerAuth: [] }],
        requestBody: { content: { "application/json": { schema: { type: "object", properties: { reason: { type: "string" } } } } } },
        responses: { 200: { description: "Account deleted" } },
      },
    },
    "/users/update_coordinates": {
      post: {
        tags: ["Users"],
        summary: "Update user location",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["latitude", "longitude"], properties: { latitude: { type: "string", example: "34.0522" }, longitude: { type: "string", example: "-118.2437" }, city: { type: "string", example: "Los Angeles", description: "Reverse geocoded by iOS via CLGeocoder" }, state: { type: "string", example: "CA", description: "Reverse geocoded by iOS via CLGeocoder" } } } } } },
        responses: { 200: { description: "Updated user" } },
      },
    },
    "/users/search_by_user_name": {
      get: {
        tags: ["Users"],
        summary: "Search users by username",
        security: [{ bearerAuth: [] }],
        parameters: [{ in: "query", name: "user_name", required: true, schema: { type: "string" } }],
        responses: { 200: { description: "{ friendships: [User], users: [User] }" } },
      },
    },
    "/users/report": {
      post: {
        tags: ["Users"],
        summary: "Report a user",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "multipart/form-data": { schema: { type: "object", required: ["user_id", "reason"], properties: { user_id: { type: "integer" }, reason: { type: "string" }, image: { type: "string", format: "binary" } } } } } },
        responses: { 200: { description: "Reported" } },
      },
    },
    "/users/send_message_invite": {
      post: {
        tags: ["Users"],
        summary: "Get invite deep link for a phone number",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["phone_number"], properties: { phone_number: { type: "string" } } } } } },
        responses: { 200: { description: "{ invite_url: string }" } },
      },
    },
    "/users/my_setting": {
      get: {
        tags: ["Users"],
        summary: "Get current user settings",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Setting object" } },
      },
    },
    "/users/edit_setting": {
      post: {
        tags: ["Users"],
        summary: "Update user settings",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", properties: { everyone: { type: "boolean" }, male_only: { type: "boolean" }, female_only: { type: "boolean" }, min_age: { type: "integer" }, max_age: { type: "integer" }, max_distace: { type: "integer" }, general: { type: "boolean" }, friendship: { type: "boolean" }, match: { type: "boolean" }, group: { type: "boolean" }, chat: { type: "boolean" } } } } } },
        responses: { 200: { description: "Updated setting" } },
      },
    },
    "/photos/upload_photo": {
      post: {
        tags: ["Photos"],
        summary: "Upload a photo",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "multipart/form-data": { schema: { type: "object", required: ["image", "order"], properties: { image: { type: "string", format: "binary" }, order: { type: "integer" }, is_primary: { type: "boolean" } } } } } },
        responses: { 200: { description: "Updated user with photos" } },
      },
    },
    "/photos/delete_photo": {
      delete: {
        tags: ["Photos"],
        summary: "Delete a photo",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["id"], properties: { id: { type: "integer" } } } } } },
        responses: { 200: { description: "Updated user with photos" } },
      },
    },
    "/photos/set_order": {
      post: {
        tags: ["Photos"],
        summary: "Reorder a photo",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["id", "order"], properties: { id: { type: "integer" }, order: { type: "integer" }, is_primary: { type: "boolean" } } } } } },
        responses: { 200: { description: "Updated user with photos" } },
      },
    },
    "/groups/create": {
      post: {
        tags: ["Groups"],
        summary: "Create a group",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["friend_ids"], properties: { friend_ids: { type: "string", example: "2,3,4", description: "Comma-separated friend user IDs" } } } } } },
        responses: { 200: { description: "Created group" } },
      },
    },
    "/groups/add_member": {
      post: {
        tags: ["Groups"],
        summary: "Add a friend to your group",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["group_id", "friend_id"], properties: { group_id: { type: "integer" }, friend_id: { type: "integer" } } } } } },
        responses: { 200: { description: "Updated group" } },
      },
    },
    "/groups/my_group": {
      get: {
        tags: ["Groups"],
        summary: "Get my current group",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Group or null" } },
      },
    },
    "/groups/leave_group": {
      delete: {
        tags: ["Groups"],
        summary: "Leave your group",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "OK" } },
      },
    },
    "/groups/group_by_id": {
      get: {
        tags: ["Groups"],
        summary: "Get group by ID",
        security: [{ bearerAuth: [] }],
        parameters: [{ in: "query", name: "group_id", required: true, schema: { type: "integer" } }],
        responses: { 200: { description: "Group" } },
      },
    },
    "/matches/find_groups": {
      get: {
        tags: ["Matches"],
        summary: "Get swipe deck (paginated groups)",
        security: [{ bearerAuth: [] }],
        parameters: [{ in: "query", name: "page", required: true, schema: { type: "integer", example: 1 } }],
        responses: { 200: { description: "Paginated groups" } },
      },
    },
    "/matches/like_group": {
      post: {
        tags: ["Matches"],
        summary: "Like a group",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["group_id"], properties: { group_id: { type: "string" } } } } } },
        responses: { 200: { description: "Match or null" } },
      },
    },
    "/matches/unlike_group": {
      post: {
        tags: ["Matches"],
        summary: "Unlike a group",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["group_id"], properties: { group_id: { type: "string" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/matches/my_matches": {
      get: {
        tags: ["Matches"],
        summary: "Get all my matches",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Array of matches" } },
      },
    },
    "/matches/unmatch_group": {
      delete: {
        tags: ["Matches"],
        summary: "Unmatch a group",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["group_id"], properties: { group_id: { type: "string" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/friendships/direct_friendship": {
      post: {
        tags: ["Friendships"],
        summary: "Add friend by phone or get invite link",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["phone_number"], properties: { phone_number: { type: "string" } } } } } },
        responses: { 200: { description: "{ user, invite_url }" } },
      },
    },
    "/friendships/friendes": {
      get: {
        tags: ["Friendships"],
        summary: "Get all accepted friends",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Array of users" } },
      },
    },
    "/friendships/all_friends_and_requests": {
      post: {
        tags: ["Friendships"],
        summary: "Get friends and pending received requests",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Array of users with status" } },
      },
    },
    "/friendships/received_requests": {
      post: {
        tags: ["Friendships"],
        summary: "Get received friend requests",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Array of users" } },
      },
    },
    "/friendships/no_relation": {
      post: {
        tags: ["Friendships"],
        summary: "Find contacts with no relation",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["contacts"], properties: { contacts: { type: "string", example: "+14155551234,+14155555678" } } } } } },
        responses: { 200: { description: "Array of users" } },
      },
    },
    "/friendships/friends_and_no_relation": {
      post: {
        tags: ["Friendships"],
        summary: "Classify contacts as friends or non-existing",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["contacts"], properties: { contacts: { type: "string", example: "+14155551234,+14155555678" } } } } } },
        responses: { 200: { description: "{ friendships: [User], non_existing: [string] }" } },
      },
    },
    "/friendships/request": {
      post: {
        tags: ["Friendships"],
        summary: "Send a friend request",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["friend_id"], properties: { friend_id: { type: "integer" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/friendships/accept": {
      post: {
        tags: ["Friendships"],
        summary: "Accept a friend request",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["friend_id"], properties: { friend_id: { type: "integer" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/friendships/reject": {
      post: {
        tags: ["Friendships"],
        summary: "Reject a friend request",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["friend_id"], properties: { friend_id: { type: "integer" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/friendships/block": {
      post: {
        tags: ["Friendships"],
        summary: "Block a user",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "multipart/form-data": { schema: { type: "object", required: ["friend_id"], properties: { friend_id: { type: "integer" }, reason: { type: "string" }, image: { type: "string", format: "binary" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/friendships/unfriend": {
      post: {
        tags: ["Friendships"],
        summary: "Unfriend a user",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["friend_id"], properties: { friend_id: { type: "integer" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/friendships/blocked": {
      get: {
        tags: ["Friendships"],
        summary: "Get blocked users",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Array of users" } },
      },
    },
    "/friendships/unblock": {
      post: {
        tags: ["Friendships"],
        summary: "Unblock users",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["block_users"], properties: { block_users: { type: "string", example: "2,3" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/friendships/status": {
      get: {
        tags: ["Friendships"],
        summary: "Get friendship status with a user",
        security: [{ bearerAuth: [] }],
        parameters: [{ in: "query", name: "friend_id", required: true, schema: { type: "integer" } }],
        responses: { 200: { description: "{ status: string }" } },
      },
    },
    "/notifications/send_notification": {
      post: {
        tags: ["Notifications"],
        summary: "Send a test push notification to yourself",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["message"], properties: { message: { type: "string" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
    "/devices/update_device_token": {
      post: {
        tags: ["Devices"],
        summary: "Register or update FCM device token",
        security: [{ bearerAuth: [] }],
        requestBody: { required: true, content: { "application/json": { schema: { type: "object", required: ["physical_address", "fcm_token", "device_type"], properties: { physical_address: { type: "string" }, fcm_token: { type: "string" }, device_type: { type: "string", example: "iphone" } } } } } },
        responses: { 200: { description: "OK" } },
      },
    },
  },
};
