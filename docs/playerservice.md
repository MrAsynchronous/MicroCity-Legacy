# PlayerService

Listens for PlayerAdded and PlayerRemoving events.  Constructs a PseudoPlayer for each Player as well as handles Client HTTP Requests.

### Server Methods

| Returns | Method |
| ---------| ---------- |
| `PseudoPlayer` | `PlayerService:GetPseudoPlayer(Player player)` |

### Client Methods

| Returns | Method | 
| ---------| ---------- |
| `Model` | `PlayerService.Client:RequestPlot(Player player)` |