import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// We will create these screens shortly. For now, creating placeholders.
import '../screens/auth/role_selector_page.dart';
import '../screens/admin/admin_layout.dart';
import '../screens/admin/dashboard_page.dart';
import '../screens/admin/heat_map_detail_page.dart';
import '../screens/admin/priority_control_page.dart';
import '../screens/admin/volunteer_mgmt_page.dart';
import '../screens/admin/dispatch_queue_page.dart';
import '../screens/admin/campaign_mgmt_page.dart';
import '../screens/admin/ingestion_monitor_page.dart';
import '../screens/admin/analytics_page.dart';
import '../screens/admin/admin_settings_page.dart';
import '../screens/volunteer/volunteer_layout.dart';
import '../screens/volunteer/task_feed_page.dart';
import '../screens/volunteer/map_view_page.dart';
import '../screens/volunteer/my_tasks_page.dart';
import '../screens/volunteer/volunteer_profile_page.dart';
import '../screens/auth/onboarding_page.dart';
import '../screens/auth/volunteer_auth_page.dart';
import '../screens/auth/admin_auth_page.dart';
import '../screens/auth/field_auth_page.dart';
import '../screens/volunteer/task_detail_page.dart';
import '../screens/volunteer/check_in_page.dart';
import '../screens/volunteer/notifications_page.dart';
import '../screens/volunteer/volunteer_settings_page.dart';
import '../screens/field/field_layout.dart';
import '../screens/field/survey_form_page.dart';
import '../screens/field/sync_queue_page.dart';
import '../models/need.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleSelectorPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/volunteer/auth',
      builder: (context, state) => const VolunteerAuthPage(),
    ),
    GoRoute(
      path: '/admin/auth',
      builder: (context, state) => const AdminAuthPage(),
    ),
    GoRoute(
      path: '/field/auth',
      builder: (context, state) => const FieldAuthPage(),
    ),
    GoRoute(
      path: '/volunteer/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/volunteer/task_detail',
      builder: (context, state) => TaskDetailPage(task: state.extra as Need),
    ),
    GoRoute(
      path: '/volunteer/check_in',
      builder: (context, state) => const CheckInPage(),
    ),
    GoRoute(
      path: '/volunteer/settings',
      builder: (context, state) => const VolunteerSettingsPage(),
    ),
    // Admin Surface Routes
    ShellRoute(
      builder: (context, state, child) {
        return AdminLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/admin/heatmap',
          builder: (context, state) => const HeatMapDetailPage(),
        ),
        GoRoute(
          path: '/admin/priority',
          builder: (context, state) => const PriorityControlPage(),
        ),
        GoRoute(
          path: '/admin/volunteers',
          builder: (context, state) => const VolunteerManagementPage(),
        ),
        GoRoute(
          path: '/admin/dispatch',
          builder: (context, state) => const DispatchQueuePage(),
        ),
        GoRoute(
          path: '/admin/campaigns',
          builder: (context, state) => const CampaignManagementPage(),
        ),
        GoRoute(
          path: '/admin/ingestion',
          builder: (context, state) => const DataIngestionMonitorPage(),
        ),
        GoRoute(
          path: '/admin/analytics',
          builder: (context, state) => const AnalyticsPage(),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (context, state) => const AdminSettingsPage(),
        ),
      ],
    ),
    // Volunteer Surface Routes
    ShellRoute(
      builder: (context, state, child) {
        return VolunteerLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/volunteer/feed',
          builder: (context, state) => const TaskFeedPage(),
        ),
        GoRoute(
          path: '/volunteer/map',
          builder: (context, state) => const MapViewPage(),
        ),
        GoRoute(
          path: '/volunteer/tasks',
          builder: (context, state) => const MyTasksPage(),
        ),
        GoRoute(
          path: '/volunteer/profile',
          builder: (context, state) => const VolunteerProfilePage(),
        ),
      ],
    ),
    // Field Data Entry Surface Routes
    ShellRoute(
      builder: (context, state, child) {
        return FieldLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/field/survey',
          builder: (context, state) => const SurveyFormPage(),
        ),
        GoRoute(
          path: '/field/sync',
          builder: (context, state) => const SyncQueuePage(),
        ),
      ],
    ),
  ],
);
