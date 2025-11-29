# MySpace: A MindSanctuary - System Overview

## Demo Accounts

You can use these accounts to explore the application:

### User Accounts
- **Username**: human_gorilla  
  **Email**: user2@myspace.com  
  **Password**: d+fTeOaCu4s7

- **Username**: fine_unicorn  
  **Email**: user@myspace.com  
  **Password**: JeUI9XnnpTCg

### Admin Account
- **Email**: admin1@myspace.com  
  **Password**: uQJ0jRxi5q+Y

---

MySpace: A MindSanctuary is a comprehensive mental wellness and support platform built with Phoenix LiveView for reactive UI and Phoenix Channels for real-time communication. The platform focuses on supporting survivors of Gender-based Violence, providing mentorship, community support, and mental wellness tools in a safe, private environment.

## Core Features

* **Authentication & Identity** (email sign-up, role-based access, user profiles)

* **Mood Tracker** (daily emotional check-ins, pattern visualization, wellness analytics)

* **Resource Hub** (curated mental health resources, articles, SOS contacts, helplines)

* **Live Chat System** (real-time messaging, public and private chat, mentorship connections)

* **Support Boards** (community forums, experience sharing, peer support)

* **Mentorship Program** (mentor-mentee matching, application system, guidance sessions)

* **Wellness Calendar** (schedule management, appointment tracking, wellness activities)

* **Dashboard** (personal overview, quick stats, recent activity)

* **Admin & Volunteer Management** (manage resources, moderate content, user management)

## Key Focus Areas

* **Gender-based Violence Support** (dedicated resources, survivor empowerment, ally creation)
* **Community Building** (peer support, shared experiences, collective healing)
* **Mentorship Connections** (experienced guidance, personalized support, growth opportunities)
* **Mental Wellness Tools** (mood tracking, habit building, clarity exercises)

## Implemented Features (Current)

1. **Authentication System** (email registration, login, user roles)
2. **Mood Tracker** with timeline and analytics
3. **Resource Hub** with SOS contacts and helplines
4. **Live Chat** (public and private messaging)
5. **Support Boards** (community forums)
6. **Mentorship Program** (applications and matching)
7. **Wellness Calendar** (scheduling and events)
8. **Dashboard** (personal overview)
9. **Modern UI** (glassmorphism design, gradients, responsive layout)

## Future Enhancements

* **Advanced Analytics** (sentiment analysis, pattern recognition)
* **Video Calling** (face-to-face mentorship sessions)
* **Mobile App** (iOS/Android applications)
* **AI Support** (smart suggestions, personalized insights)
* **Workshop Integration** (scheduled events, RSVP system)
* **Advanced Moderation** (AI-powered content filtering)


# Endpoints & LiveViews (Current Implementation)

* `/` — Landing page with feature overview
* `/users/register` — User registration LiveView
* `/users/log-in` — User login LiveView  
* `/dashboard` — Personal dashboard LiveView
* `/mood` — Mood tracker LiveView
* `/calendar` — Wellness calendar LiveView
* `/resources` — Resource hub LiveView
* `/resources/new` — Create new resource LiveView
* `/resources/:id/edit` — Edit resource LiveView
* `/resources/:id` — View resource details LiveView
* `/chat` — Public chat LiveView
* `/chat/:id` — Private chat LiveView
* `/posts` — Support boards LiveView
* `/posts/:id` — Individual post LiveView
* `/mentorship` — Mentorship program LiveView
* `/mentorship/manage` — Mentorship management LiveView
* `/users/settings` — User settings LiveView

# Technical Implementation Details

## Architecture
* **Frontend**: Phoenix LiveView with modern glassmorphism UI design
* **Backend**: Phoenix with Ecto and PostgreSQL
* **Real-time**: Phoenix Channels for live messaging
* **Authentication**: Phoenix built-in auth system with role-based access
* **File Storage**: Resource files and media handling

## Database Schemas
* **Users** (authentication, roles, profiles)
* **MoodEntries** (daily check-ins, emotional tracking)
* **Resources** (mental health resources, SOS contacts)
* **Chats** (public and private messaging)
* **Messages** (chat messages with user associations)
* **Posts** (community support board posts)
* **Mentorships** (mentor-mentee relationships and applications)

## Current Status Checklist

* [x] Phoenix app scaffolded with LiveView
* [x] PostgreSQL + Ecto configured
* [x] Authentication system implemented
* [x] Mood tracker UI and database
* [x] Resource hub with SOS contacts
* [x] Live chat system (public & private)
* [x] Support boards for community
* [x] Mentorship program with applications
* [x] Wellness calendar system
* [x] Modern responsive UI design
* [x] Dashboard with personal overview
* [x] Real-time messaging with Phoenix Channels
* [x] Role-based access control
* [x] GBV-focused resources and support

## Development Philosophy

* **User-Centered Design**: Focus on survivor empowerment and safety
* **Privacy First**: All interactions designed with user privacy as priority
* **Community Building**: Foster supportive peer connections
* **Accessible Interface**: Modern, intuitive UI that works across devices
* **Real-time Support**: Live chat and mentorship connections
* **Comprehensive Care**: From immediate help to long-term wellness tools

## Key Differentiators

* **GBV Specialization**: Dedicated focus on gender-based violence support
* **Mentorship Network**: Experienced mentors providing personalized guidance
* **Community Support**: Peer-to-peer support through forums and chat
* **Integrated Wellness**: Combines crisis support with ongoing mental wellness tools
* **Safe Environment**: Moderated spaces with user safety as top priority