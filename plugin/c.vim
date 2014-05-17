"************************************************************
" * Author        : song
" * Email         : song11210312@126.com
" * Last modified : 2014-05-15 10:44
" * Filename      : c.vim
" * Description   : c.vim更改版
" 更改了该插件的功能，删除了不经常用的功能，留下了关键字补全功能，可以设置自己的关键字列表，加入到对应的文件中
" * **********************************************************

if v:version < 700
  echohl WarningMsg | echo 'The plugin c.vim needs Vim version 7+.'| echohl None
  finish
endif
"
" Prevent duplicate loading:
"
if exists("g:C_Version") || &cp
 finish
endif
let g:C_Version= "6.1.1"								" version number of this script; do not change
"
"#################################################################################
"  Global variables (with default values) which can be overridden.
"
" Platform specific items:  {{{1
" - root directory
" - characters that must be escaped for filenames
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let s:plugin_dir						= ''
let s:C_FilenameEscChar 		= ''

if	s:MSWIN
  " ==========  MS Windows  ======================================================
	"
	let s:plugin_dir	= substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )
	"
  let s:C_FilenameEscChar 			= ''
	"
else
  " ==========  Linux/Unix  ======================================================
	"
	let s:plugin_dir	= expand('<sfile>:p:h:h')
	"
  let s:C_FilenameEscChar 			= ' \%#[]'
	"
endif
"
"  Use of dictionaries  {{{1
"  Key word completion is enabled by the filetype plugin 'c.vim'
"  g:C_Dictionary_File  must be global
"
if !exists("g:C_Dictionary_File")				"加入自己的关键字列表，比如glib库德关键字列表
  let g:C_Dictionary_File = s:plugin_dir.'/c-support/wordlists/c-c++-keywords.list,'.
        \                   s:plugin_dir.'/c-support/wordlists/k+r.list,'.
        \                   s:plugin_dir.'/c-support/wordlists/stl_index.list,'.
        \                   s:plugin_dir.'/c-support/wordlists/glib-keywords.list'
"		\                   s:plugin_dir.'/c-support/wordlists/gtk3.0-keywords.list'
endif

"
let s:C_CExtension     				= 'c'                    " C file extension; everything else is C++
let s:C_LoadMenus      				= 'yes'
let s:C_CreateMenusDelayed    = 'no'
let s:C_OutputGvim            = 'vim'
let s:C_RootMenu  	   				= '&C\/C\+\+.'           " the name of the root menu of this plugin
let s:C_TypeOfH               = 'cpp'
"
"
let s:C_MenusVisible          = 'no'		" state variable controlling the C-menus
"
"------------------------------------------------------------------------------
"  C : C_InitMenus                              {{{1
"  Initialization of C support menus
"------------------------------------------------------------------------------
"
function! s:C_InitMenus ()
	"
	if ! has ( 'menu' )
		return
	endif
	"
	exe 'amenu '.s:C_RootMenu.'C\/C\+\+ <Nop>'
	exe 'amenu '.s:C_RootMenu.'-Sep00-  <Nop>'
endfunction    " ----------  end of function  s:C_InitMenus  ----------
"

"------------------------------------------------------------------------------
"  C_CreateGuiMenus     {{{1
"------------------------------------------------------------------------------
function! C_CreateGuiMenus ()
	if s:C_MenusVisible == 'no'
		aunmenu <silent> &Tools.Load\ C\ Support
		amenu   <silent> 40.1000 &Tools.-SEP100- :
		amenu   <silent> 40.1030 &Tools.Unload\ C\ Support <C-C>:call C_RemoveGuiMenus()<CR>
		call s:C_InitMenus()
		let  s:C_MenusVisible = 'yes'
	endif
endfunction    " ----------  end of function C_CreateGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  C_ToolMenu     {{{1
"------------------------------------------------------------------------------
function! C_ToolMenu ()
	amenu   <silent> 40.1000 &Tools.-SEP100- :
	amenu   <silent> 40.1030 &Tools.Load\ C\ Support      :call C_CreateGuiMenus()<CR>
	imenu   <silent> 40.1030 &Tools.Load\ C\ Support <C-C>:call C_CreateGuiMenus()<CR>
endfunction    " ----------  end of function C_ToolMenu  ----------

"------------------------------------------------------------------------------
"  C_RemoveGuiMenus     {{{1
"------------------------------------------------------------------------------
function! C_RemoveGuiMenus ()
	if s:C_MenusVisible == 'yes'
		exe "aunmenu <silent> ".s:C_RootMenu
		"
		aunmenu <silent> &Tools.Unload\ C\ Support
		call C_ToolMenu()
		"
		let s:C_MenusVisible = 'no'
	endif
endfunction    " ----------  end of function C_RemoveGuiMenus  ----------
"===  FUNCTION  ================================================================
"          NAME:  CreateAdditionalMaps     {{{1
"   DESCRIPTION:  create additional maps
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! s:CreateAdditionalMaps ()
	"
	" ---------- C/C++ dictionary -----------------------------------
	" This will enable keyword completion for C and C++
	" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
	" Set the new dictionaries in front of the existing ones
	" 
	if exists("g:C_Dictionary_File")
		silent! exe 'setlocal dictionary+='.g:C_Dictionary_File
	endif    
	"
endfunction    " ----------  end of function s:CreateAdditionalMaps  ----------
"
"------------------------------------------------------------------------------
"  show / hide the c-support menus
"  define key mappings (gVim only)
"------------------------------------------------------------------------------
"
call C_ToolMenu()
"
if s:C_LoadMenus == 'yes' && s:C_CreateMenusDelayed == 'no'
	call C_CreateGuiMenus()
endif
"
"------------------------------------------------------------------------------
"  Automated header insertion
"  Local settings for the quickfix window
"
"			Vim always adds the {cmd} after existing autocommands,
"			so that the autocommands execute in the order in which
"			they were given. The order matters!
"------------------------------------------------------------------------------
if has("autocmd")
	"
	"  *.h has filetype 'cpp' by default; this can be changed to 'c' :
	"
	if s:C_TypeOfH=='c'
		autocmd BufNewFile,BufEnter  *.h  :set filetype=c
	endif
	"
	" C/C++ source code files which should not be preprocessed.
	"
	autocmd BufNewFile,BufRead  *.i  :set filetype=c
	autocmd BufNewFile,BufRead  *.ii :set filetype=cpp
	"
	" DELAYED LOADING OF THE TEMPLATE DEFINITIONS
	"
	autocmd FileType *
				\	if ( &filetype == 'cpp' || &filetype == 'c') |
				\		if s:C_LoadMenus == 'yes' | call C_CreateGuiMenus ()        |
				\		endif |
				\		call s:CreateAdditionalMaps() |
				\	endif

		"-------------------------------------------------------------------------------
		" style switching :Automated header insertion (suffixes from the gcc manual)
		"-------------------------------------------------------------------------------
			if !exists( 'g:C_Styles' )
				"-------------------------------------------------------------------------------
				" template styles are the default settings
				"-------------------------------------------------------------------------------
				autocmd BufNewFile  * if &filetype =~ '^\(c\|cpp\)$' && expand("%:e") !~ 'ii\?'
				"
			endif
	"
	" Wrap error descriptions in the quickfix window.
	"
	autocmd BufReadPost quickfix  setlocal wrap | setlocal linebreak
	"
	"
endif " has("autocmd")
"
