# Diagram Generation with PlantUML

Text-based diagram creation for software architecture, workflows, and system design.

## Core Implementation

```plantuml
@startuml system-architecture

!theme cerulean-outline
!define RECTANGLE class

title System Architecture Diagram

' Define components and relationships
package "Frontend Layer" {
  [Web App] as webapp
  [Mobile App] as mobile
  [Admin Panel] as admin
}

package "API Gateway" {
  [Load Balancer] as lb
  [API Router] as router
  [Auth Service] as auth
}

package "Business Logic" {
  [User Service] as users
  [Order Service] as orders
  [Payment Service] as payments
  [Notification Service] as notifications
}

package "Data Layer" {
  database "User DB" as userdb
  database "Order DB" as orderdb
  database "Cache" as cache
  queue "Message Queue" as mq
}

' Define connections
webapp --> lb
mobile --> lb
admin --> lb

lb --> router
router --> auth
router --> users
router --> orders
router --> payments

users --> userdb
orders --> orderdb
payments --> mq
notifications --> mq

orders --> cache
users --> cache

' Add notes and styling
note right of auth : JWT Token\nValidation
note bottom of mq : Redis/RabbitMQ\nAsync Processing

@enduml

@startuml sequence-flow

title API Request Flow

actor User
participant "Web App" as web
participant "API Gateway" as api
participant "Auth Service" as auth
participant "User Service" as service
database "Database" as db

User -> web: Login Request
web -> api: POST /auth/login
api -> auth: Validate Credentials
auth -> db: Query User
db --> auth: User Data
auth --> api: JWT Token
api --> web: Auth Response
web --> User: Login Success

User -> web: Get Profile
web -> api: GET /user/profile\n[Authorization: Bearer Token]
api -> auth: Validate Token
auth --> api: Token Valid
api -> service: Get User Profile
service -> db: Query Profile
db --> service: Profile Data
service --> api: Profile Response
api --> web: User Profile
web --> User: Display Profile

@enduml
```

## Key Features
- Multiple diagram types (sequence, class, activity, component)
- Automatic layout and routing
- Theme and styling customization
- Integration with documentation workflows
- Export to SVG, PNG, and PDF formats
- Collaborative editing through text-based source