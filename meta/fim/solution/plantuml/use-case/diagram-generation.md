# PlantUML Diagram Generation - NPL-FIM Complete Guide

**Morgan Black's Comprehensive PlantUML Implementation Guide**

*Advanced text-based diagram creation for software architecture, workflows, system design, and technical documentation with immediate NPL-FIM artifact generation capabilities.*

## Direct Unramp - Quick Start Templates

### Immediate Use Architecture Diagram
```plantuml
@startuml quick-architecture
!theme cerulean-outline
!define COMPONENT rectangle
!define DATABASE database
!define QUEUE queue

title {{PROJECT_NAME}} System Architecture

package "Frontend" {
  COMPONENT [Web App] as web
  COMPONENT [Mobile App] as mobile
  COMPONENT [Admin Panel] as admin
}

package "Gateway" {
  COMPONENT [Load Balancer] as lb
  COMPONENT [API Gateway] as gateway
  COMPONENT [Auth Service] as auth
}

package "Services" {
  COMPONENT [{{SERVICE_1}}] as svc1
  COMPONENT [{{SERVICE_2}}] as svc2
  COMPONENT [{{SERVICE_3}}] as svc3
}

package "Data" {
  DATABASE "{{DB_NAME}}" as db
  DATABASE "Cache" as cache
  QUEUE "Message Queue" as mq
}

' Connections
web --> lb
mobile --> lb
admin --> lb
lb --> gateway
gateway --> auth
gateway --> svc1
gateway --> svc2
gateway --> svc3
svc1 --> db
svc2 --> db
svc3 --> mq
svc1 --> cache

@enduml
```

### Ready-to-Use Sequence Diagram
```plantuml
@startuml api-sequence
!theme aws-orange
title {{API_NAME}} Request Flow

actor "{{USER_ROLE}}" as user
participant "{{CLIENT_APP}}" as client
participant "{{API_GATEWAY}}" as gateway
participant "{{SERVICE_NAME}}" as service
database "{{DATABASE}}" as db

user -> client: {{ACTION_NAME}}
client -> gateway: {{HTTP_METHOD}} {{ENDPOINT}}
activate gateway
gateway -> service: {{INTERNAL_CALL}}
activate service
service -> db: {{DB_OPERATION}}
activate db
db --> service: {{RESULT_DATA}}
deactivate db
service --> gateway: {{RESPONSE_DATA}}
deactivate service
gateway --> client: {{HTTP_RESPONSE}}
deactivate gateway
client --> user: {{USER_FEEDBACK}}

@enduml
```

## Complete Environment Setup

### Installation Requirements

**Java Runtime (Required)**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install default-jre

# macOS
brew install openjdk

# Windows (Chocolatey)
choco install openjdk

# Verify installation
java -version
```

**PlantUML JAR Download**
```bash
# Download latest PlantUML JAR
wget -O plantuml.jar "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"

# Alternative: specific version
wget -O plantuml.jar "https://sourceforge.net/projects/plantuml/files/plantuml.1.2023.13.jar/download"

# Set executable permissions
chmod +x plantuml.jar
```

**VS Code Integration**
```json
{
  "plantuml.server": "https://www.plantuml.com/plantuml",
  "plantuml.render": "PlantUMLServer",
  "plantuml.includepaths": ["./diagrams", "./docs"],
  "plantuml.exportOutDir": "./output",
  "plantuml.exportFormat": "svg",
  "plantuml.exportSubFolder": true
}
```

**IntelliJ IDEA Plugin**
- Install "PlantUML Integration" plugin
- Configure PlantUML path: File → Settings → Tools → PlantUML
- Set JAR location: `/path/to/plantuml.jar`

### Command Line Usage
```bash
# Generate PNG
java -jar plantuml.jar diagram.puml

# Generate SVG (recommended for web)
java -jar plantuml.jar -tsvg diagram.puml

# Generate PDF
java -jar plantuml.jar -tpdf diagram.puml

# Batch processing
java -jar plantuml.jar -tsvg "*.puml"

# Watch mode for development
java -jar plantuml.jar -tsvg -gui
```

## Comprehensive Diagram Types

### 1. Component Architecture Diagrams

**Microservices Architecture**
```plantuml
@startuml microservices-architecture
!theme mars
!define MICROSERVICE component
!define EXTERNAL rectangle
!define STORAGE database

title Microservices Architecture Pattern

cloud "Internet" {
  EXTERNAL [Load Balancer] as lb
}

package "API Gateway Layer" {
  MICROSERVICE [API Gateway] as gateway
  MICROSERVICE [Auth Service] as auth
  MICROSERVICE [Rate Limiter] as rate
}

package "Business Services" {
  MICROSERVICE [User Service] as user_svc
  MICROSERVICE [Order Service] as order_svc
  MICROSERVICE [Payment Service] as payment_svc
  MICROSERVICE [Inventory Service] as inventory_svc
  MICROSERVICE [Notification Service] as notify_svc
}

package "Data Layer" {
  STORAGE "User DB\n(PostgreSQL)" as user_db
  STORAGE "Order DB\n(MongoDB)" as order_db
  STORAGE "Payment DB\n(PostgreSQL)" as payment_db
  STORAGE "Cache\n(Redis)" as cache
  queue "Event Bus\n(Kafka)" as kafka
}

package "External Services" {
  EXTERNAL [Payment Gateway] as pay_gateway
  EXTERNAL [Email Service] as email
  EXTERNAL [SMS Service] as sms
}

' Connections
lb --> gateway
gateway --> auth
gateway --> rate
gateway --> user_svc
gateway --> order_svc
gateway --> payment_svc
gateway --> inventory_svc

user_svc --> user_db
order_svc --> order_db
payment_svc --> payment_db
inventory_svc --> cache

user_svc --> kafka
order_svc --> kafka
payment_svc --> kafka
kafka --> notify_svc

payment_svc --> pay_gateway
notify_svc --> email
notify_svc --> sms

' Styling and notes
note right of auth : JWT Validation\nOAuth2 Support
note bottom of kafka : Event-Driven\nAsync Communication
note right of cache : Session Storage\nQuery Caching

@enduml
```

**Layered Architecture**
```plantuml
@startuml layered-architecture
!theme vibrant
title {{APPLICATION_NAME}} Layered Architecture

package "Presentation Layer" {
  [Web UI] as web_ui
  [REST API] as rest_api
  [GraphQL API] as graphql_api
}

package "Application Layer" {
  [{{FEATURE_1}} Controller] as ctrl1
  [{{FEATURE_2}} Controller] as ctrl2
  [{{FEATURE_3}} Controller] as ctrl3
  [Validation Service] as validation
  [Mapping Service] as mapping
}

package "Business Logic Layer" {
  [{{DOMAIN_1}} Service] as biz1
  [{{DOMAIN_2}} Service] as biz2
  [{{DOMAIN_3}} Service] as biz3
  [Business Rules Engine] as rules
  [Event Publisher] as events
}

package "Data Access Layer" {
  [{{ENTITY_1}} Repository] as repo1
  [{{ENTITY_2}} Repository] as repo2
  [{{ENTITY_3}} Repository] as repo3
  [Unit of Work] as uow
  [Cache Manager] as cache_mgr
}

package "Infrastructure Layer" {
  database "{{PRIMARY_DB}}" as primary_db
  database "{{READ_DB}}" as read_db
  database "Cache" as cache
  queue "Message Queue" as mq
  cloud "External APIs" as external
}

' Layer connections
web_ui --> ctrl1
rest_api --> ctrl1
rest_api --> ctrl2
graphql_api --> ctrl3

ctrl1 --> validation
ctrl1 --> biz1
ctrl2 --> validation
ctrl2 --> biz2
ctrl3 --> mapping
ctrl3 --> biz3

biz1 --> rules
biz1 --> repo1
biz2 --> rules
biz2 --> repo2
biz3 --> events
biz3 --> repo3

repo1 --> uow
repo2 --> uow
repo3 --> uow
uow --> primary_db
repo1 --> cache_mgr
cache_mgr --> cache

events --> mq
biz2 --> external

' Read model
repo1 --> read_db
repo2 --> read_db

@enduml
```

### 2. Sequence Diagrams

**Authentication Flow**
```plantuml
@startuml auth-sequence
!theme sketchy-outline
title {{APPLICATION}} Authentication Flow

actor "User" as user
participant "{{CLIENT_APP}}" as client
participant "API Gateway" as gateway
participant "Auth Service" as auth
participant "User Service" as user_svc
database "User Database" as user_db
database "Session Store" as session

== Login Process ==
user -> client: Enter Credentials
client -> gateway: POST /auth/login\n{email, password}
activate gateway

gateway -> auth: Validate Login Request
activate auth
auth -> user_svc: Verify Credentials
activate user_svc
user_svc -> user_db: SELECT user WHERE email = ?
user_db --> user_svc: User Record
user_svc -> user_svc: Verify Password Hash
user_svc --> auth: User Validated
deactivate user_svc

auth -> auth: Generate JWT Token
auth -> session: Store Session\n{user_id, token, expires}
session --> auth: Session Created
auth --> gateway: {token, user_info, expires_in}
deactivate auth

gateway --> client: 200 OK\n{access_token, refresh_token}
deactivate gateway
client -> client: Store Tokens
client --> user: Login Successful

== Authenticated Request ==
user -> client: Request Protected Resource
client -> gateway: GET /api/{{RESOURCE}}\nAuthorization: Bearer {{TOKEN}}
activate gateway

gateway -> auth: Validate Token
activate auth
auth -> session: Check Session Status
session --> auth: Session Valid
auth -> auth: Verify JWT Signature
auth --> gateway: Token Valid + User Context
deactivate auth

gateway -> user_svc: GET {{RESOURCE}}\nUser: {{USER_ID}}
activate user_svc
user_svc -> user_db: Query {{RESOURCE}} Data
user_db --> user_svc: {{RESOURCE}} Data
user_svc --> gateway: {{RESOURCE}} Response
deactivate user_svc

gateway --> client: 200 OK\n{{RESOURCE}} Data
deactivate gateway
client --> user: Display {{RESOURCE}}

== Token Refresh ==
note over client: Token Near Expiry
client -> gateway: POST /auth/refresh\n{refresh_token}
gateway -> auth: Validate Refresh Token
auth -> session: Check Refresh Token
session --> auth: Refresh Valid
auth -> auth: Generate New Access Token
auth --> gateway: New Token Pair
gateway --> client: {new_access_token, refresh_token}

@enduml
```

**Error Handling Sequence**
```plantuml
@startuml error-handling-sequence
!theme reddress-darkblue
title Error Handling and Recovery Flow

actor "User" as user
participant "{{CLIENT}}" as client
participant "API Gateway" as gateway
participant "{{SERVICE}}" as service
participant "Error Handler" as error_handler
participant "Monitoring" as monitor
database "{{DATABASE}}" as db

== Successful Request ==
user -> client: {{ACTION}}
client -> gateway: {{HTTP_METHOD}} {{ENDPOINT}}
gateway -> service: Process Request
service -> db: {{DB_OPERATION}}
db --> service: Success Response
service --> gateway: 200 OK
gateway --> client: Success Response
client --> user: {{SUCCESS_MESSAGE}}

== Database Error Scenario ==
user -> client: {{ACTION}}
client -> gateway: {{HTTP_METHOD}} {{ENDPOINT}}
gateway -> service: Process Request
service -> db: {{DB_OPERATION}}
db --> service: **Database Connection Error**
activate error_handler

service -> error_handler: Handle DB Error
error_handler -> monitor: Log Error Event
error_handler -> service: Retry Strategy
service -> db: Retry {{DB_OPERATION}}
db --> service: **Still Failing**

error_handler -> error_handler: Circuit Breaker Activated
error_handler --> service: Return Cached/Default Data
service --> gateway: 200 OK (Degraded)
gateway --> client: Partial Success
client --> user: {{DEGRADED_MESSAGE}}

monitor -> monitor: Alert Operations Team
deactivate error_handler

== Validation Error Scenario ==
user -> client: {{ACTION}} (Invalid Data)
client -> gateway: {{HTTP_METHOD}} {{ENDPOINT}}
gateway -> gateway: Input Validation
gateway --> client: 400 Bad Request\n{validation_errors}
client --> user: Show Validation Errors

== Service Unavailable Scenario ==
user -> client: {{ACTION}}
client -> gateway: {{HTTP_METHOD}} {{ENDPOINT}}
gateway -> service: **Service Unavailable**
gateway -> error_handler: Handle Service Error
error_handler -> monitor: Log Service Outage
error_handler --> gateway: 503 Service Unavailable
gateway --> client: 503 Service Unavailable
client -> client: Implement Retry Logic
client --> user: Service Temporarily Unavailable

@enduml
```

### 3. Class Diagrams

**Domain Model**
```plantuml
@startuml domain-model
!theme blueprint
title {{DOMAIN}} Domain Model

abstract class Entity {
  +UUID id
  +DateTime createdAt
  +DateTime updatedAt
  +String createdBy
  +String updatedBy
  --
  +boolean equals(Object other)
  +int hashCode()
  +String toString()
}

abstract class AggregateRoot extends Entity {
  -List<DomainEvent> domainEvents
  --
  +void addDomainEvent(DomainEvent event)
  +List<DomainEvent> getDomainEvents()
  +void clearDomainEvents()
}

class {{MAIN_ENTITY}} extends AggregateRoot {
  -String {{PROPERTY_1}}
  -{{TYPE_2}} {{PROPERTY_2}}
  -{{ENUM}} status
  -Money {{MONEY_PROPERTY}}
  --
  +{{MAIN_ENTITY}}({{CONSTRUCTOR_PARAMS}})
  +void {{BUSINESS_METHOD_1}}()
  +{{RETURN_TYPE}} {{BUSINESS_METHOD_2}}()
  +boolean {{VALIDATION_METHOD}}()
  +void {{STATE_CHANGE_METHOD}}()
}

class {{CHILD_ENTITY}} extends Entity {
  -{{MAIN_ENTITY}} {{PARENT_REF}}
  -String {{CHILD_PROPERTY_1}}
  -{{TYPE}} {{CHILD_PROPERTY_2}}
  --
  +{{CHILD_ENTITY}}({{CONSTRUCTOR_PARAMS}})
  +void {{CHILD_METHOD}}()
  +boolean {{CHILD_VALIDATION}}()
}

class {{VALUE_OBJECT}} {
  -final String {{VALUE_PROP_1}}
  -final {{TYPE}} {{VALUE_PROP_2}}
  --
  +{{VALUE_OBJECT}}({{VALUE_PARAMS}})
  +boolean equals(Object other)
  +int hashCode()
  +String toString()
  +{{TYPE}} {{GETTER_METHOD}}()
}

enum {{STATUS_ENUM}} {
  {{STATUS_1}}
  {{STATUS_2}}
  {{STATUS_3}}
  --
  +boolean isActive()
  +boolean canTransitionTo({{STATUS_ENUM}} newStatus)
}

interface {{REPOSITORY_INTERFACE}} {
  +Optional<{{MAIN_ENTITY}}> findById(UUID id)
  +List<{{MAIN_ENTITY}}> findBy{{CRITERIA}}({{PARAMS}})
  +{{MAIN_ENTITY}} save({{MAIN_ENTITY}} entity)
  +void delete({{MAIN_ENTITY}} entity)
  +boolean exists(UUID id)
}

interface {{DOMAIN_SERVICE}} {
  +{{RESULT_TYPE}} {{SERVICE_METHOD}}({{PARAMS}})
  +boolean {{VALIDATION_SERVICE}}({{PARAMS}})
  +void {{PROCESS_METHOD}}({{PARAMS}})
}

class {{DOMAIN_EVENT}} {
  +UUID aggregateId
  +DateTime occurredOn
  +String eventType
  +Map<String, Object> eventData
  --
  +{{DOMAIN_EVENT}}({{EVENT_PARAMS}})
  +String getEventType()
  +Object getEventData(String key)
}

' Relationships
{{MAIN_ENTITY}} ||--o{ {{CHILD_ENTITY}} : contains
{{MAIN_ENTITY}} --> {{VALUE_OBJECT}} : uses
{{MAIN_ENTITY}} --> {{STATUS_ENUM}} : has status
{{MAIN_ENTITY}} ..> {{DOMAIN_EVENT}} : publishes
{{REPOSITORY_INTERFACE}} ..> {{MAIN_ENTITY}} : manages
{{DOMAIN_SERVICE}} ..> {{MAIN_ENTITY}} : operates on

' Notes
note right of {{MAIN_ENTITY}} : Aggregate Root\nBusinesss Logic Hub
note bottom of {{VALUE_OBJECT}} : Immutable\nValue Object
note left of {{DOMAIN_EVENT}} : Domain Events\nfor Integration

@enduml
```

### 4. Activity Diagrams

**Business Process Flow**
```plantuml
@startuml business-process
!theme amiga
title {{PROCESS_NAME}} Business Process

start

:{{USER_ACTION}};

if ({{VALIDATION_CONDITION}}?) then (valid)
  :{{VALIDATION_SUCCESS_ACTION}};
else (invalid)
  :{{VALIDATION_ERROR_ACTION}};
  :Show Error Message;
  stop
endif

:{{PROCESSING_STEP_1}};

fork
  :{{PARALLEL_TASK_1}};
  :{{PARALLEL_SUBTASK_1A}};
fork again
  :{{PARALLEL_TASK_2}};
  if ({{CONDITION_2}}?) then (yes)
    :{{CONDITIONAL_TASK}};
  else (no)
    :{{ALTERNATIVE_TASK}};
  endif
fork again
  :{{PARALLEL_TASK_3}};
  :{{INTEGRATION_CALL}};
end fork

:{{CONSOLIDATION_STEP}};

repeat
  :{{RETRY_OPERATION}};
  if ({{SUCCESS_CONDITION}}?) then (success)
    :{{SUCCESS_ACTION}};
    break
  else (failure)
    :{{ERROR_HANDLING}};
    if ({{RETRY_CONDITION}}?) then (retry)
      :{{RETRY_PREPARATION}};
    else (abort)
      :{{ABORT_ACTION}};
      stop
    endif
  endif
repeat while ({{RETRY_LIMIT_CHECK}})

switch ({{RESULT_TYPE}})
case ({{TYPE_A}})
  :{{TYPE_A_PROCESSING}};
case ({{TYPE_B}})
  :{{TYPE_B_PROCESSING}};
case ({{TYPE_C}})
  :{{TYPE_C_PROCESSING}};
endswitch

:{{FINAL_STEP}};

if ({{NOTIFICATION_NEEDED}}?) then (yes)
  fork
    :{{EMAIL_NOTIFICATION}};
  fork again
    :{{SMS_NOTIFICATION}};
  fork again
    :{{PUSH_NOTIFICATION}};
  end fork
endif

:{{COMPLETION_ACTION}};

stop

@enduml
```

### 5. State Diagrams

**Entity Lifecycle**
```plantuml
@startuml entity-state-diagram
!theme sketchy
title {{ENTITY_NAME}} State Lifecycle

[*] --> Created : {{CREATION_EVENT}}

Created --> Pending : {{SUBMISSION_EVENT}}
Created --> Cancelled : {{CANCELLATION_EVENT}}

Pending --> InProgress : {{START_EVENT}}
Pending --> Cancelled : {{CANCELLATION_EVENT}}
Pending --> Expired : {{TIMEOUT_EVENT}}

InProgress --> Completed : {{COMPLETION_EVENT}}
InProgress --> Failed : {{FAILURE_EVENT}}
InProgress --> Paused : {{PAUSE_EVENT}}
InProgress --> Cancelled : {{CANCELLATION_EVENT}}

Paused --> InProgress : {{RESUME_EVENT}}
Paused --> Cancelled : {{CANCELLATION_EVENT}}
Paused --> Expired : {{TIMEOUT_EVENT}}

Failed --> InProgress : {{RETRY_EVENT}}
Failed --> Cancelled : {{ABANDONMENT_EVENT}}

Completed --> [*]
Cancelled --> [*]
Expired --> [*]

' State behaviors
Created : entry / {{CREATION_ACTION}}
Created : exit / {{CREATION_CLEANUP}}

Pending : entry / {{PENDING_SETUP}}
Pending : do / {{PENDING_MONITORING}}

InProgress : entry / {{START_PROCESSING}}
InProgress : do / {{PROGRESS_TRACKING}}
InProgress : exit / {{PROGRESS_CLEANUP}}

Failed : entry / {{ERROR_LOGGING}}
Failed : do / {{ERROR_ANALYSIS}}

Completed : entry / {{COMPLETION_NOTIFICATION}}

' Guard conditions and actions
InProgress --> Completed : {{COMPLETION_EVENT}} [{{SUCCESS_CONDITION}}] / {{SUCCESS_ACTION}}
InProgress --> Failed : {{FAILURE_EVENT}} [{{FAILURE_CONDITION}}] / {{FAILURE_ACTION}}

note right of Pending : Waiting for\nresources or\napproval
note bottom of InProgress : Active processing\nwith progress tracking
note left of Failed : Temporary failure\nretry possible

@enduml
```

## Configuration and Customization

### Theme Configuration
```plantuml
' Built-in themes
!theme aws-orange          ' AWS orange theme
!theme blueprintblue       ' Blueprint style
!theme cerulean-outline    ' Clean outline style
!theme mars               ' Red Mars theme
!theme sketchy-outline    ' Hand-drawn style
!theme vibrant           ' Bright colors

' Custom theme definition
!define PRIMARY_COLOR #2E86AB
!define SECONDARY_COLOR #A23B72
!define ACCENT_COLOR #F18F01
!define BACKGROUND_COLOR #C73E1D

skinparam backgroundColor BACKGROUND_COLOR
skinparam defaultFontColor #FFFFFF
skinparam defaultFontSize 12
skinparam defaultFontName "Arial"

' Component styling
skinparam component {
  BackgroundColor PRIMARY_COLOR
  BorderColor SECONDARY_COLOR
  FontColor #FFFFFF
}

skinparam database {
  BackgroundColor ACCENT_COLOR
  BorderColor SECONDARY_COLOR
}

skinparam actor {
  BackgroundColor SECONDARY_COLOR
  BorderColor PRIMARY_COLOR
}
```

### Custom Macros and Definitions
```plantuml
' Reusable component definitions
!define WEBAPP rectangle #lightblue
!define MOBILE rectangle #lightgreen
!define API rectangle #orange
!define DATABASE database #lightcoral
!define CACHE database #yellow
!define QUEUE queue #lightpink

' Custom stereotypes
!define <<external>> #lightgray
!define <<internal>> #lightblue
!define <<deprecated>> #red

' Icon definitions (using Devicons)
!define DEVICON_POSTGRESQL <&postgresql>
!define DEVICON_REDIS <&redis>
!define DEVICON_DOCKER <&docker>
!define DEVICON_KUBERNETES <&kubernetes>

' Template macros
!definelong SERVICE(name, tech)
rectangle "name" as name {
  note : Technology: tech
}
!enddefinelong

' Usage example
SERVICE(UserService, "Spring Boot")
SERVICE(OrderService, "Node.js")
```

### Layout and Positioning
```plantuml
@startuml layout-example
!theme blueprint

' Direction control
!direction top to bottom left to right

' Manual positioning
component A
component B
component C
component D

A -right-> B
B -down-> C
C -left-> D
D -up-> A

' Grouping and spacing
together {
  component E
  component F
}

' Hidden links for layout
A -[hidden]-> E
B -[hidden]-> F

' Notes positioning
note right of A : Right side note
note bottom of B : Bottom note
note left of C : Left side note
note top of D : Top note

@enduml
```

## Integration Patterns

### Documentation Integration
```plantuml
@startuml doc-integration
!theme sketchy-outline

title Documentation Integration Workflow

package "Documentation System" {
  [Markdown Files] as md
  [PlantUML Diagrams] as puml
  [Static Site Generator] as ssg
  [Generated Site] as site
}

package "Development Tools" {
  [IDE/Editor] as ide
  [Version Control] as vcs
  [CI/CD Pipeline] as cicd
}

package "Collaboration" {
  [Wiki System] as wiki
  [Confluence] as confluence
  [Notion] as notion
}

' Integration flows
ide -> puml : Create/Edit Diagrams
puml -> md : Embed in Documentation
md -> ssg : Generate Static Site
ssg -> site : Deploy Documentation

ide -> vcs : Commit Diagrams
vcs -> cicd : Trigger Build
cicd -> ssg : Build Documentation
cicd -> site : Deploy Updates

puml -> wiki : Export to Wiki
puml -> confluence : Import Diagrams
puml -> notion : Embed Visuals

' Notes
note right of puml : Version controlled\nText-based diagrams
note bottom of ssg : Hugo, Jekyll,\nMkDocs, Docusaurus

@enduml
```

### CI/CD Integration
```yaml
# GitHub Actions example
name: Generate PlantUML Diagrams

on:
  push:
    paths:
      - '**/*.puml'
      - 'docs/**/*.md'

jobs:
  generate-diagrams:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'temurin'
        java-version: '11'

    - name: Download PlantUML
      run: |
        wget -O plantuml.jar "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"

    - name: Generate SVG diagrams
      run: |
        find . -name "*.puml" -exec java -jar plantuml.jar -tsvg {} \;

    - name: Commit generated diagrams
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add "*.svg"
        git diff --staged --quiet || git commit -m "Auto-generate PlantUML diagrams"
        git push
```

## Advanced Features and Variations

### Database Schema Diagrams
```plantuml
@startuml database-schema
!theme blueprint

title {{PROJECT_NAME}} Database Schema

' Entity relationship diagram
entity "{{TABLE_1}}" as t1 {
  * id : UUID <<PK>>
  --
  * {{FIELD_1}} : VARCHAR(255) <<NOT NULL>>
  * {{FIELD_2}} : INTEGER <<NOT NULL>>
  {{FIELD_3}} : TEXT
  {{FIELD_4}} : TIMESTAMP
  * created_at : TIMESTAMP <<NOT NULL>>
  * updated_at : TIMESTAMP <<NOT NULL>>
}

entity "{{TABLE_2}}" as t2 {
  * id : UUID <<PK>>
  --
  * {{FK_FIELD}} : UUID <<FK>>
  * {{FIELD_1}} : VARCHAR(100) <<NOT NULL>>
  {{FIELD_2}} : DECIMAL(10,2)
  * status : ENUM('active','inactive') <<NOT NULL>>
}

entity "{{JUNCTION_TABLE}}" as jt {
  * {{TABLE_1}}_id : UUID <<PK,FK>>
  * {{TABLE_2}}_id : UUID <<PK,FK>>
  --
  * created_at : TIMESTAMP <<NOT NULL>>
  {{ADDITIONAL_FIELD}} : VARCHAR(50)
}

' Relationships
t1 ||--o{ t2 : "has many"
t1 }o--o{ jt : "links"
t2 }o--o{ jt : "links"

' Indexes
note right of t1 : Indexes:\n- idx_{{FIELD_1}}\n- idx_created_at
note left of t2 : Indexes:\n- idx_{{FK_FIELD}}\n- idx_status

@enduml
```

### API Documentation Diagrams
```plantuml
@startuml api-documentation
!theme aws-orange

title {{API_NAME}} REST API Structure

package "Authentication" {
  [POST /auth/login] as auth_login
  [POST /auth/refresh] as auth_refresh
  [POST /auth/logout] as auth_logout
}

package "{{RESOURCE_1}} Management" {
  [GET /{{RESOURCE_1}}] as get_all
  [GET /{{RESOURCE_1}}/{id}] as get_one
  [POST /{{RESOURCE_1}}] as create
  [PUT /{{RESOURCE_1}}/{id}] as update
  [DELETE /{{RESOURCE_1}}/{id}] as delete
}

package "{{RESOURCE_2}} Operations" {
  [GET /{{RESOURCE_2}}] as res2_list
  [POST /{{RESOURCE_2}}/{id}/{{ACTION}}] as res2_action
}

database "{{DATABASE}}" as db
queue "{{MESSAGE_QUEUE}}" as mq

' Authentication flow
auth_login --> db : Validate credentials
auth_refresh --> db : Check refresh token

' CRUD operations
get_all --> db : SELECT with pagination
get_one --> db : SELECT by ID
create --> db : INSERT new record
create --> mq : Publish creation event
update --> db : UPDATE record
update --> mq : Publish update event
delete --> db : SOFT DELETE
delete --> mq : Publish deletion event

' Special operations
res2_action --> db : Complex query
res2_action --> mq : Async processing

' API documentation notes
note right of auth_login : Request:\n{\n  "email": "string",\n  "password": "string"\n}\n\nResponse:\n{\n  "token": "string",\n  "expires_in": 3600\n}

note bottom of create : Request:\n{\n  "{{FIELD_1}}": "string",\n  "{{FIELD_2}}": "number"\n}\n\nResponse: 201 Created\n{\n  "id": "uuid",\n  "{{FIELD_1}}": "string",\n  "created_at": "datetime"\n}

@enduml
```

### Deployment Architecture
```plantuml
@startuml deployment-diagram
!theme cerulean-outline

title {{PROJECT_NAME}} Deployment Architecture

cloud "{{CLOUD_PROVIDER}}" {

  package "Production Environment" {
    node "Load Balancer" as lb {
      artifact "{{LB_TYPE}}" as lb_service
    }

    node "Web Tier" as web_tier {
      artifact "{{WEB_APP}}" as web1
      artifact "{{WEB_APP}}" as web2
      artifact "{{WEB_APP}}" as web3
    }

    node "API Tier" as api_tier {
      artifact "{{API_SERVICE}}" as api1
      artifact "{{API_SERVICE}}" as api2
      artifact "{{WORKER_SERVICE}}" as worker
    }

    node "Data Tier" as data_tier {
      database "{{PRIMARY_DB}}" as primary_db
      database "{{READ_REPLICA}}" as read_db
      database "{{CACHE}}" as cache
      queue "{{MESSAGE_QUEUE}}" as mq
    }
  }

  package "Monitoring & Logging" {
    node "Observability" as obs {
      artifact "{{MONITORING_TOOL}}" as monitoring
      artifact "{{LOGGING_TOOL}}" as logging
      artifact "{{TRACING_TOOL}}" as tracing
    }
  }

  package "CI/CD Infrastructure" {
    node "Build Pipeline" as cicd {
      artifact "{{CI_TOOL}}" as ci
      artifact "{{REGISTRY}}" as registry
      artifact "{{DEPLOYMENT_TOOL}}" as deploy
    }
  }
}

' External services
cloud "External Services" {
  artifact "{{PAYMENT_SERVICE}}" as payment
  artifact "{{EMAIL_SERVICE}}" as email
  artifact "{{CDN}}" as cdn
}

' Network connections
lb_service --> web1
lb_service --> web2
lb_service --> web3

web1 --> api1
web2 --> api1
web3 --> api2

api1 --> primary_db
api2 --> primary_db
api1 --> read_db
api2 --> read_db
api1 --> cache
api2 --> cache

worker --> mq
api1 --> mq
api2 --> mq

' External integrations
api1 --> payment
api2 --> email
web1 --> cdn

' Monitoring connections
monitoring --> web_tier
monitoring --> api_tier
monitoring --> data_tier
logging --> web_tier
logging --> api_tier

' Deployment flow
ci --> registry
registry --> deploy
deploy --> web_tier
deploy --> api_tier

' Infrastructure notes
note right of lb : {{LB_DETAILS}}\nSSL Termination\nHealth Checks

note bottom of web_tier : Auto-scaling\n{{MIN_INSTANCES}}-{{MAX_INSTANCES}} instances\n{{INSTANCE_TYPE}}

note left of data_tier : {{DB_DETAILS}}\nBackup Strategy\nFailover Config

@enduml
```

## Troubleshooting Guide

### Common Issues and Solutions

**Java Path Issues**
```bash
# Error: Java not found
export JAVA_HOME=/usr/lib/jvm/default-java
export PATH=$JAVA_HOME/bin:$PATH

# Verify Java installation
java -version
which java
```

**Memory Issues with Large Diagrams**
```bash
# Increase memory allocation
java -Xmx1024m -jar plantuml.jar large-diagram.puml

# For very large diagrams
java -Xmx2048m -jar plantuml.jar complex-system.puml
```

**Syntax Errors**
```plaintext
Common PlantUML syntax errors:

1. Missing @startuml/@enduml tags
2. Incorrect arrow syntax (use --> not ->)
3. Reserved keywords as identifiers
4. Unmatched parentheses or brackets
5. Invalid theme names
6. Circular dependencies in class diagrams

Solutions:
- Use PlantUML syntax checker
- Validate with online editor
- Check parentheses matching
- Verify theme names exist
```

**Font and Rendering Issues**
```plantuml
' Font configuration
skinparam defaultFontName "DejaVu Sans"
skinparam defaultFontSize 10
skinparam defaultFontStyle plain

' High DPI rendering
skinparam dpi 300
```

**Export Format Issues**
```bash
# SVG for web (recommended)
java -jar plantuml.jar -tsvg diagram.puml

# PNG with transparency
java -jar plantuml.jar -tpng diagram.puml

# PDF for printing
java -jar plantuml.jar -tpdf diagram.puml

# Multiple formats
java -jar plantuml.jar -tsvg -tpng diagram.puml
```

### Performance Optimization

**Large Diagram Optimization**
```plantuml
' Reduce complexity
!define SIMPLIFY_LAYOUT
!pragma useVerticalIf on

' Optimize connections
!define ARROW_LENGTH 2
skinparam minClassWidth 50
skinparam minClassHeight 50

' Reduce font sizes for overview diagrams
skinparam defaultFontSize 8
```

**Batch Processing**
```bash
# Process multiple files efficiently
java -jar plantuml.jar -tsvg -o ./output *.puml

# Parallel processing (Linux/macOS)
find . -name "*.puml" -print0 | xargs -0 -P 4 -I {} java -jar plantuml.jar -tsvg {}
```

## Tool-Specific Advantages

### PlantUML Strengths
- **Text-based**: Version control friendly, diff-able
- **Automatic layout**: No manual positioning required
- **Multiple formats**: SVG, PNG, PDF export options
- **Integration ready**: Works with documentation tools
- **Collaborative**: Easy to share and modify
- **Programmatic**: Can be generated from code/data

### PlantUML Limitations
- **Limited styling**: Less visual customization than GUI tools
- **Layout control**: Sometimes produces suboptimal layouts
- **Complex diagrams**: Can become unwieldy for very large systems
- **Learning curve**: Syntax must be learned
- **Performance**: Large diagrams can be slow to render

### Best Use Cases
- Software architecture documentation
- API documentation and specifications
- Database schema visualization
- Process flow documentation
- Team collaboration on system design
- Automated diagram generation
- Integration with development workflows

### When NOT to Use PlantUML
- Highly stylized presentations
- Marketing materials requiring precise branding
- Diagrams requiring pixel-perfect positioning
- Non-technical stakeholder presentations
- Real-time collaborative editing requirements

## Migration and Integration Strategies

### From Visual Tools
```plaintext
Migrating from Visio/Lucidchart/Draw.io:

1. Start with simple diagrams
2. Learn PlantUML syntax gradually
3. Use online converter tools where available
4. Focus on content over visual perfection
5. Leverage text-based advantages (version control, automation)
```

### Integration with Existing Workflows
```yaml
# Documentation workflow integration
docs/
├── diagrams/
│   ├── architecture/
│   │   ├── system-overview.puml
│   │   ├── microservices.puml
│   │   └── deployment.puml
│   ├── api/
│   │   ├── authentication.puml
│   │   └── user-flows.puml
│   └── database/
│       ├── schema.puml
│       └── migrations.puml
├── generated/
│   ├── *.svg
│   └── *.png
└── content/
    ├── architecture.md
    └── api-reference.md
```

This comprehensive guide provides everything needed for NPL-FIM to generate effective PlantUML diagrams with immediate unramp capabilities, complete examples, and professional-grade documentation standards.