# Pixso 页面与实现对照

[浅色总览](overview-light.jpg) · [深色总览](overview-dark.jpg) · [测试记录](TESTING.md)

42 个原始画板均通过 MCP 读取并导出。原稿采用多个画板描述同一页面的播放、滚动、展开或输入状态，实现中共享组件。截图由 Android 模拟器集成测试产生，不是原始设计图。

| Pixso 画板 | 节点 | 原始设计 | 应用截图 |
| --- | --- | --- | --- |
| Profile 1 - Dark | `0:2` | [设计](reference/01-profile-1-dark.png) | [截图](screenshots/dark-08-profile.png) |
| Profile scroll - Dark | `0:190` | [设计](reference/02-profile-scroll-dark.png) | [截图](screenshots/dark-10-profile-scrolled.png) |
| Profile swipe down - Dark | `0:490` | [设计](reference/03-profile-swipe-down-dark.png) | [截图](screenshots/dark-09-profile-expanded.png) |
| Home | `0:786` | [设计](reference/04-home.png) | [截图](screenshots/light-02-home.png) |
| Home - Dark | `105:2743` | [设计](reference/05-home-dark.png) | [截图](screenshots/dark-02-home.png) |
| Home - playing bg - Dark | `650:21695` | [设计](reference/06-home-playing-bg-dark.png) | [截图](screenshots/dark-03-home-playing.png) |
| Home - playing bg | `2:3474` | [设计](reference/07-home-playing-bg.png) | [截图](screenshots/light-03-home-playing.png) |
| My books | `0:1595` | [设计](reference/08-my-books.png) | [截图](screenshots/light-07-library.png) |
| My books | `650:23221` | [设计](reference/09-my-books.png) | [截图](screenshots/dark-07-library.png) |
| Search | `0:1635` | [设计](reference/10-search.png) | [截图](screenshots/light-04-search.png) |
| Search | `650:22346` | [设计](reference/11-search.png) | [截图](screenshots/dark-04-search.png) |
| Slapsh screen | `253:3114` | [设计](reference/12-slapsh-screen.png) | [截图](screenshots/light-01-welcome.png) |
| Slapsh screen | `670:5323` | [设计](reference/13-slapsh-screen.png) | [截图](screenshots/dark-01-welcome.png) |
| Search when scrolling | `0:1666` | [设计](reference/14-search-when-scrolling.png) | [截图](screenshots/light-05-search-scrolled.png) |
| Search when scrolling | `650:22354` | [设计](reference/15-search-when-scrolling.png) | [截图](screenshots/dark-05-search-scrolled.png) |
| Profile | `0:1679` | [设计](reference/16-profile.png) | [截图](screenshots/light-08-profile.png) |
| Profile scroll | `0:1859` | [设计](reference/17-profile-scroll.png) | [截图](screenshots/light-10-profile-scrolled.png) |
| Profile swipe down | `0:2176` | [设计](reference/18-profile-swipe-down.png) | [截图](screenshots/light-09-profile-expanded.png) |
| Now Playing - off | `0:2465` | [设计](reference/19-now-playing-off.png) | [截图](screenshots/light-11-player-paused.png) |
| Now Playing - off | `650:24006` | [设计](reference/20-now-playing-off.png) | [截图](screenshots/dark-11-player-paused.png) |
| Now Playing - on | `2:4099` | [设计](reference/21-now-playing-on.png) | [截图](screenshots/light-12-player-playing.png) |
| Now Playing - on | `650:24055` | [设计](reference/22-now-playing-on.png) | [截图](screenshots/dark-12-player-playing.png) |
| Search Filter | `0:2526` | [设计](reference/23-search-filter.png) | [截图](screenshots/light-06-filter.png) |
| Search Filter | `651:29009` | [设计](reference/24-search-filter.png) | [截图](screenshots/dark-06-filter.png) |
| Checkout - save on | `0:2587` | [设计](reference/25-checkout-save-on.png) | [截图](screenshots/light-13-checkout-save.png) |
| Checkout - save on | `650:24105` | [设计](reference/26-checkout-save-on.png) | [截图](screenshots/dark-13-checkout-save.png) |
| Checkout - save off | `2:3108` | [设计](reference/27-checkout-save-off.png) | [截图](screenshots/light-14-checkout-unsaved.png) |
| Checkout - save off | `650:24156` | [设计](reference/28-checkout-save-off.png) | [截图](screenshots/dark-14-checkout-unsaved.png) |
| About | `0:2638` | [设计](reference/29-about.png) | [截图](screenshots/light-15-about.png) |
| About | `650:24207` | [设计](reference/30-about.png) | [截图](screenshots/dark-15-about.png) |
| Registration | `0:2681` | [设计](reference/31-registration.png) | [截图](screenshots/light-16-registration.png) |
| Registration | `650:24250` | [设计](reference/32-registration.png) | [截图](screenshots/dark-16-registration.png) |
| Registration 2 | `0:3117` | [设计](reference/33-registration-2.png) | [截图](screenshots/light-20-registration-full.png) |
| Registration 3 | `650:24686` | [设计](reference/34-registration-3.png) | [截图](screenshots/dark-20-registration-full.png) |
| Registration 4 | `650:28865` | [设计](reference/35-registration-4.png) | [截图](screenshots/dark-21-login-full.png) |
| Login 2 | `0:3556` | [设计](reference/36-login-2.png) | [截图](screenshots/light-21-login-full.png) |
| Login | `0:3978` | [设计](reference/37-login.png) | [截图](screenshots/light-17-login.png) |
| Login | `650:25547` | [设计](reference/38-login.png) | [截图](screenshots/dark-17-login.png) |
| Reset Password | `0:4397` | [设计](reference/39-reset-password.png) | [截图](screenshots/light-18-reset.png) |
| Reset Password | `650:25966` | [设计](reference/40-reset-password.png) | [截图](screenshots/dark-18-reset.png) |
| Create new password | `0:4815` | [设计](reference/41-create-new-password.png) | [截图](screenshots/light-19-password.png) |
| Create new password | `650:26384` | [设计](reference/42-create-new-password.png) | [截图](screenshots/dark-19-password.png) |

另有电子书、无结果搜索、表单校验三张补充截图；全屏注册和登录页也分别覆盖浅色与深色主题。封面分类为宣传素材；Symbols 为设计组件库，未作为应用页面。



