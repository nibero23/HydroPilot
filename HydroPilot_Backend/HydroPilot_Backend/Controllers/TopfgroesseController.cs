// ============================================================
// Controllers/TopfgroesseController.cs
// ============================================================

using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/topfgroessen")]
public class TopfgroesseController : ControllerBase
{
    private readonly AppRepository _repo;

    public TopfgroesseController(AppRepository repo)
    {
        _repo = repo;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Topfgroesse>>> GetAlleTopfgroessen()
    {
        var groessen = await _repo.GetAlleTopfgroessenAsync();
        return Ok(groessen);
    }
}
