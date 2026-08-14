Nguyễn Văn Chiến - Sat, 8 Aug 2026, 2:15 PM

English: Platform Connecting the Film Photography Community with Darkroom and Studio Services

3.1.2. Vietnamese: Nền tảng kết nối cộng đồng nhiếp ảnh phim với các dịch vụ phòng tối và phòng chụp

(*) 3.2. Main proposal content (including result and product)

## a) Context:

Film photography has experienced a significant revival in recent years, attracting an increasing number of enthusiasts who appreciate the artistic value and analog workflow of film-based photography. Along with this growing community, the demand for creative spaces such as darkrooms, photography studios, specialized equipment, and supporting services has also increased.
Despite this growth, these resources remain fragmented. Film photographers often rely on social media groups, personal contacts, or individual websites to search for available darkrooms or studios. Booking availability, equipment inquiries, pricing, and confirmations are usually handled manually through phone calls or messaging applications. This process is inefficient, time-consuming, and lacks transparency for both customers and service providers.
From the service providers' perspective, managing creative spaces, photography equipment, consumable materials, maintenance schedules, reservations, and business operations is often performed using spreadsheets or multiple disconnected software solutions. As a result, resource utilization is not optimized, scheduling conflicts frequently occur, and business performance is difficult to analyze.
Currently, there is no integrated platform dedicated to connecting the film photography community with providers of darkrooms, photography studios, and related creative resources. This limits resource sharing, reduces operational efficiency, and weakens collaboration within the community.
Therefore, this project proposes the development of a digital platform that connects photographers with service providers while supporting intelligent resource sharing, reservation management, community interaction, and business operation management in a unified ecosystem.

## b) Proposed Solutions:
The proposed system is a multi-sided platform designed to connect film photographers with service providers offering darkrooms, photography studios, photography equipment, and supporting creative services.
Instead of functioning as a traditional booking application, the platform focuses on managing and sharing creative resources. Service providers can publish and manage multiple creative spaces, equipment inventories, consumable materials, and customizable service packages through a centralized system.
Photographers can search, compare, and reserve resources based on various criteria such as location, room type, artistic style, capacity, available equipment, pricing, operating hours, and community reviews. During the reservation process, the system automatically verifies the availability of all required resources to prevent scheduling conflicts.
The platform also supports business management by providing reservation tracking, maintenance scheduling, resource lifecycle management, revenue analysis, and operational dashboards. In addition, community features allow photographers and experts to share experiences, publish tutorials, organize workshops, and exchange knowledge related to film photography.
Artificial Intelligence is incorporated to personalize service recommendations, optimize resource allocation, forecast booking demand, restore old photographs, enhance scanned film images, and provide an intelligent assistant capable of answering photography-related questions.
- System Roles
1. Photographer (Customer) : Photographers are users who reserve creative spaces and supporting resources for photography activities. Main responsibilities include:
- Manage personal profile
- Search and compare darkrooms and studios
- View detailed information about creative spaces
- Reserve rooms and equipment
- Purchase or customize service packages
- Make online payments
- View reservation history
- Manage digital photo collections
- Submit reviews and ratings
- Participate in community activities and workshops
2. Service Provider: Service providers are individuals or organizations that own and operate one or more darkrooms, photography studios, equipment inventories, or creative facilities. Main responsibilities include:
- Manage business profile
- Manage darkrooms and photography studios
- Configure room specifications and availability
- Manage photography equipment and consumable resources
- Create and manage service packages
- Configure pricing policies and promotional campaigns
- Process reservation requests
- Allocate resources for confirmed bookings
- Monitor room occupancy and equipment utilization
- Schedule equipment maintenance
- Analyze revenue and business performance through dashboards
3. Photography Expert: Photography experts contribute professional knowledge to the platform. Main responsibilities include:
- Publish educational articles
- Organize workshops and training sessions
- Review photography equipment
- Share darkroom techniques and best practices
- Build the community knowledge base
4. Administrator: Administrators oversee platform operations and ensure system reliability. Main responsibilities include:
- Manage users and service providers
- Approve provider registrations
- Manage categories and platform content
- Monitor transactions and payments
- Handle disputes and complaints
- Manage AI services and platform configurations
- Generate system-wide reports
5. AI Assistant: The AI Assistant provides intelligent support for both customers and service providers. Main responsibilities include:
- Recommend suitable creative spaces
- Suggest equipment and service packages
- Restore and enhance digital photographs
- Answer photography-related questions
- Support semantic search within the knowledge base
* AI Applications such as:
- Personalized recommendation system for rooms, equipment, and service packages
- Intelligent resource allocation optimization
- Booking demand forecasting
- Dynamic pricing recommendations
- Image restoration and enhancement
- AI-powered photography assistant
- Semantic search within the community knowledge base
- Research-Based Learning (RBL)
Research Topics
- Resource Scheduling and Allocation Algorithms
- Recommendation Systems
- Artificial Intelligence for Creative Service Platforms
- Computer Vision for Image Restoration
- Demand Forecasting
- Semantic Search and Knowledge Retrieval
- Multi-sided Platform Design

## c) Functional Requirements:
*** Business Core Flows:
Core Flow 1. Creative Space Management
Service providers create and maintain detailed profiles for each creative space available on the platform. Every darkroom or studio contains comprehensive information including room dimensions, maximum capacity, artistic style, lighting conditions, ventilation, acoustic characteristics, supporting facilities, operating hours, usage policies, pricing models, images, and available amenities. The platform continuously monitors each room's availability to support accurate reservation planning.
Core Flow 2. Resource and Equipment Management
The platform manages all reusable resources associated with creative spaces, including cameras, lenses, enlargers, film scanners, lighting systems, tripods, backgrounds, darkroom processing equipment, and consumable materials such as chemicals and photographic paper.
Each resource maintains its own lifecycle information including availability, maintenance schedule, operational condition, rental pricing, compatibility with service packages, and historical utilization records.
Core Flow 3. Reservation and Resource Allocation
Photographers select creative spaces, rental periods, equipment, and additional services according to their needs. Before confirming a reservation, the system verifies the availability of every required resource and automatically detects scheduling conflicts.
Once approved, the reservation locks all related resources during the selected time period and updates the reservation calendar for every associated asset.
Core Flow 4. Service Session Management
During the reservation period, customers check in using their booking information or QR code. The system records actual usage duration, allocated equipment, additional services consumed, and checkout status.
These operational records are used for billing, service evaluation, equipment tracking, and dispute resolution when necessary.
Core Flow 5. Service Package Management
Service providers can combine creative spaces, equipment, consumable resources, instructors, and supporting services into flexible service packages designed for different photography activities such as portrait photography, product photography, film developing, darkroom printing, or educational workshops.
The platform automatically validates resource availability before allowing customers to reserve complete service packages.
Core Flow 6. Community Knowledge Sharing
The platform enables photographers and experts to exchange knowledge through articles, tutorials, equipment reviews, photography techniques, workshop announcements, and discussions.
Content is organized into a searchable knowledge repository that supports continuous learning and community engagement.

## d) Non-Functional Requirements:
- Average system response time shall remain below three seconds under normal operating conditions.
- The platform shall support concurrent reservations while preventing scheduling conflicts through transaction-safe resource allocation.
- Authentication and authorization shall be implemented using JWT and OAuth 2.0 with role-based access control.
- The system shall adopt a modular architecture separating mobile, web, backend, and AI services to improve scalability and maintainability.
- Cloud infrastructure shall provide secure storage, automatic backup, and disaster recovery capabilities.
- The platform shall be designed to accommodate future expansion, allowing additional creative spaces, equipment categories, and business services to be integrated without major architectural modifications.

## e) Theory & Practical:
Theory and Practice (Document)
- Mobile Application: Flutter (Android & iOS)
- Web Portal: ReactJS / Next.js
- Backend: ASP.NET Core Web API or Node.js (Express)
- Database: PostgreSQL or MySQL
- Cloud Storage: Microsoft Azure Blob Storage / Firebase Storage
- Authentication: JWT & OAuth 2.0
- AI Integration: OpenAI API, Recommendation Systems, Computer Vision
- Maps & Location Services: Google Maps API
- Online Payment: VNPay, MoMo, Stripe
- Cloud Deployment: Microsoft Azure / Firebase
- Version Control: GitHub
The project combines software engineering principles with resource reservation systems, cloud computing, artificial intelligence, recommendation systems, and digital community platforms to build a comprehensive ecosystem for the film photography community.

## f) Products (Expected Deliverables):
Products
The expected deliverables include:
- A cross-platform mobile application for photographers.
- A web portal for service providers to manage creative spaces, equipment, reservations, and business operations.
- A web-based administration system for platform management.
- AI modules for recommendation, resource optimization, image restoration, and intelligent assistance.
- A knowledge-sharing and community platform dedicated to film photography.

## g) Proposed Tasks:
Proposed Tasks
No. Task Responsibility
1 System requirement analysis, software architecture design, database design, and backend API development
2 Development of the Flutter mobile application, including search, reservation, payment, community interaction, and personal profile management 1
3 Development of the web portal for service providers and administrators, including creative space management, equipment management, reservation scheduling, business dashboards, and reporting 2
4 Research and implementation of AI modules, including recommendation systems, resource allocation optimization, booking demand forecasting, image restoration, semantic search, and AI assistant integration 3
5 System integration, software testing, deployment, technical documentation, user manual preparation, and final Capstone report All s
4. Other comments (propose all relative things if have):