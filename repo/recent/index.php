<?php

require_once '../opentheory.php';

///////////////////////////////////////////////////////////////////////////////
// Constants.
///////////////////////////////////////////////////////////////////////////////

define('RECENT_PACKAGE_LIMIT',10);

///////////////////////////////////////////////////////////////////////////////
// Main page.
///////////////////////////////////////////////////////////////////////////////

$title = 'Recent Uploads';

$main =
'<h2>Recently Uploaded Packages</h2>' .
pretty_recent_packages(RECENT_PACKAGE_LIMIT);

$image = site_image('katoomba.jpg','Katoomba Scenic Railway');

output(array('title' => $title), $main, $image);

?>
