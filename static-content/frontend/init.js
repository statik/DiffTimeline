
function setup_global_drop()
{
    var zone_a = $('.global_compare_recipient_a');
    var zone_b = $('.global_compare_recipient_b');

    zone_a.droppable({
        drop: function(evt, ui) {
            zone_a.children().remove();
            zone_a.append($(ui.draggable).clone());
            $(ui.helper).remove();
            Project.state.check_comparison(zone_a, zone_b);
        }
    });

    zone_b.droppable({
        drop: function(evt, ui) {
            zone_b.children().remove();
            zone_b.append($(ui.draggable).clone());
            $(ui.helper).remove();
            Project.state.check_comparison(zone_a, zone_b);
        }
    });
}

ich.grabTemplates();

var branch_list;

$(document).ready(function() {
    branch_list = new BranchLister();
    setup_global_drop();
    $(document).scrollTo( { top: 0, left: 0 } );
});

