/**
 * Created by fritx on 5/7/14.
 */

(function () {

  var pageBase = 'p/';
  var pageExt = 'md';
  var mainPage = location.search.slice(1)
    .replace(/&.*/, '') || 'Android/index';
  var mainTitle = '';
  var onlineUrl = 'https://yutellite.github.io/blog/' +
    location.search.replace(/&.*/, '');


  function config() {
    marked.setOptions({
      renderer: new marked.Renderer(),
      gfm: true,
      tables: true,
      breaks: false,
      pedantic: false,
      sanitize: false,
      smartLists: true,
      smartypants: false
    });
  }

  function render(data, options, callback) {
    marked(data, options, callback);
  }

  function load(sel, page, isMain, options, callback) {
    isMain = isMain || false;
    var url = pageBase + page + '.' + pageExt;
    $.ajax({
      url: url,
      error: onNotFound,
      success: function (data) {
        render(data, options, function (err, html) {
          if (err && callback) return callback(err);
          var $el = $(sel);
          $el.hide().html(html).attr('data-loaded', true);

          $el.find('[src]').each(function () {
            var $el = $(this);
            $el.attr('src', function (x, old) {
              if (isAbsolute(old)) {
                return old;
              }
              return url.replace(
                new RegExp('[^\\/]*$', 'g'), ''
              ) + old;
            });
          });

          $el.find('[href]').each(function () {
            var $el = $(this);
            $el.attr('href', function (x, old) {
              if (isAbsolute(old)) {
                $el.attr('target', '_blank');
                return old;
              }
              var prefixed = url.replace(
                new RegExp('^' + pageBase + '|[^\\/]*$', 'g'), ''
              ) + old;
              var regExt = new RegExp('\\.' + pageExt + '$');
              if (!regExt.test(old)) {
                if (!/(^\.|\/\.?|\.html?)$/.test(old)) {
                  $el.attr('target', '_blank');
                }
                return prefixed;
              }
              return '?' + prefixed.replace(regExt, '');
            });
          });

          if (isMain) {
            mainTitle = $el.find('h1:first').text();
            $('title').text(function (x, old) {
              return mainTitle + ' - ' + old;
            });

            /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
            window.disqus_shortname = 'yutellite'; // required: replace example with your forum shortname
            window.disqus_title = mainTitle;
            window.disqus_identifier = mainPage;
            window.disqus_url = onlineUrl;

            /* * * DON'T EDIT BELOW THIS LINE * * */
            (function () {
              var dsq = document.createElement('script');
              dsq.type = 'text/javascript';
              dsq.async = true;
              dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
              document.getElementsByTagName('body')[0].appendChild(dsq);
            })();
          }

          $el.show();
          if (callback) callback();
        });
      }
    });
  }

  function onNotFound() {
    if (!$('#main-page').attr('data-loaded')) location.href = '.';
  }

  function start() {
    load('#sidebar-page', 'sidebar');
    load('#main-page', mainPage, true);
  }

  function isAbsolute(url) {
    return !url.indexOf('//') || !!~url.indexOf('://');
  }


  config();
  start();

})();

;(function(){

  var names = [
    '2010072611150872',
    '2010072611151106',
    '2010072611151148'
  ]
  var ext = '.gif'

  var src = 'p/ducks/' + sample(names) + ext
  $('<img>').addClass('duck')
    .attr('src', src)
    .appendTo('body')


  function sample(arr){
    var idx = parseInt(Math.random() * arr.length)
    return arr[idx] || null
  }

})()



