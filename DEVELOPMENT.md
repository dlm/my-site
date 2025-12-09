# Development Notes

## Site Architecture

This Hugo site was redesigned from a legacy academic website with modern CSS practices and semantic HTML5.

### Key Design Decisions

**Layout**: Moved from sidebar navigation to horizontal header-based nav for better visual hierarchy
**CSS Architecture**: Uses CSS variables for colors and typography, semantic element selectors over IDs where possible
**Typography**: Rem-based font system with Georgia for content, Trebuchet MS for UI elements
**Colors**: Warm academic palette with `--brown`, `--orange`, `--gray` defined as CSS variables

### Hugo Configuration

**Social Links**: Defined in `hugo.toml` under `[params.social]`, accessed via `.Site.Params.social.twitter` etc.
**Navigation**: Uses Hugo's menu system with active state detection via `{{ if eq $.RelPermalink .URL }}`
**Templates**: Clean semantic structure with `baseof.html` layout and specialized `index.html` for about page

### CSS Patterns

**Variables**: All colors and font sizes defined in `:root` for consistency
**Typography Scale**: 
- `--font-size-base: 1rem` (body text)
- `--font-size-xl: 2.25rem` (site title)
- `--font-size-small: 0.75rem` (navigation)

**Layout**: 
- `#wrapper`: 800px fixed width container with background image borders
- Flexbox for navigation layout
- CSS float for image text wrapping (like LaTeX wrapfig)

### Hugo Gotchas

- Hugo template variables use PascalCase: `.Site.Params` (not `.site.params`)
- TOML config uses lowercase: `[params.social]` but accessed as `.Site.Params.social`
- Active navigation requires exact URL matching with `$.RelPermalink`

### File Structure

```
layouts/
  _default/baseof.html    # Main template
  index.html              # About page with floating headshot
static/css/styles.css     # Single CSS file with variables
hugo.toml                 # Site config with social links
```

### Blog System

**Implementation**: Full blog functionality with Hugo's content management
**Structure**: 
- `content/blog/` directory for blog posts
- `layouts/blog/list.html` - clean table-like list of posts (title + date)
- `layouts/blog/single.html` - individual post template

**Design Decisions**:
- Table-like blog list similar to Mitchell Hashimoto's writing page
- Semantic HTML: `<ul>` and `<li>` for blog list instead of `<article>` elements
- Minimal design - no summaries or "read more" links, just title and date
- Hugo's Chroma for syntax highlighting in code blocks

**Styling**:
- Code blocks: Dark brown background with orange left border accent
- Inline code: Subtle translucent dark brown background
- Typography: Consistent use of CSS variables for all font sizing
- Color inheritance: `main` element sets base text color once
- Accessibility: Focus states matching hover states for keyboard navigation

### CSS Architecture Improvements

**Variables**: Added `--dark-brown-subtle` for translucent backgrounds
**Inheritance**: Centralized color setting in `main` element, removed repetitive declarations
**Consistency**: All font sizes use CSS variables instead of hard-coded values
**Accessibility**: Added `:focus` states for keyboard navigation

### Next Steps

- Responsive design (currently desktop-focused with 800px wrapper)
- Image handling in blog posts
- Test responsive behavior across devices

### Color Scheme

```css
--bg-main: #F5E5C5      /* Page background */
--orange: #FFB03B        /* Accent color */
--brown: #B64926         /* Primary content bg */
--dark-brown: #5C1600    /* Darker accent */
--gray: #F0F0F0          /* Text color (optimized for readability) */
--black: #000            /* Headers and borders */
```