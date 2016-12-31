/**
 * Acquisition script for CIS: Instructions (all sessions)
 */

//var urladd= "?worker_id=tWid&assignment_id=tAid&hit_id=tHid&Session=Consent" ;window.history.pushState({'page_id': 1, 'user_id': 5}, 'blah', 'acq1_Instructions.html' + urladd); console.log('URL parameters manually added')
//var urladd= "?worker_id=tWid&assignment_id=tAid&hit_id=tHid&Session=Practice"; window.history.pushState({'page_id': 1, 'user_id': 5}, 'blah', 'acq1_Instructions.html' + urladd); console.log('URL parameters manually added')
//var urladd= "?worker_id=tWid&assignment_id=tAid&hit_id=tHid&Session=Learn";window.history.pushState({'page_id': 1, 'user_id': 5}, 'blah', 'acq1_Instructions.html' + urladd); console.log('URL parameters manually added')
//var urladd= "?worker_id=tWid&assignment_id=tAid&hit_id=tHid&Session=Choice&srcstim=['bird','cat','elephant','fish']&chostim= [349,53,369,66,269,14,272,75,287,237,159,178,263,64,325,211,45,210,55,239,149,174,233,223,112,87,310,29,49,195,276,114,58,119,28,190,2,301,158,307,302,298,188,260,249,156,236,313,107,342,347,355,116,327,218,264,42,348,13,245,143,200,187,199,266,173,361,329,253,267,191,80,117,54,123,376,289,25,280, 373,265,242,335,208,51,366,82,110,224,344,213,26,306,52,358,368,281,250,222,125,324,109,41,103,97,115,362, 18,285,27,160,221,132,74,93,167,262,219,106,295,83,205,254,155,23,186,317,227,341,375,345,57,283,247,164,55,189,32,231,48,50,35,297,351,284,73,234,68,76,133,12,162,128,43,134,357,177,94,209,72,39,225,34,316,59,126,3,7,62,65,40,179,24,141,145,5,70,138,229,248,78,206,22,257,244,46,343,150,157,246,181,153,273,102,60,340,336,105,204,113,217,198,334,294,356,286,251,185,21,243,275,122,130,380,6,256,100,63,194,183,88,359,326]";  window.history.pushState({'page_id': 1, 'user_id': 5}, 'blah', 'acq1_Instructions.html' + urladd); console.log('URL parameters manually added')

// Overall setup
log.ntrials_practice = 16;                                          // Practice session
var query = opGetQueryParams(document.location.search),
    dp_stim1 =   shuffle(opLinFromTo(1,log.ntrials_practice ,1)),
    dp_choice= new Array(log.ntrials_practice).fill(999),
    dp_acc =  shuffle(opLinspace(0,1, log.ntrials_practice).map(s => Math.round(s))),
    pn= 0,
    wp;

// Event/Operation function #############################
var doInstruc= function() {                 // Arrow to the correct bit of the Instructions
    //$('.StimPresInstruc').css({
    //    //"background-color": "red",
    //    "position": "relative", "left":"50%",
    //    "transform":"translate(-50%, 0%)",
    //    //"background-color": "blue",
    //}).show();
    switch (query.Session) {
        case "Consent":
            erlink= document.location.pathname.substring(0,document.location.pathname.indexOf('h1_Instructions')) + 'h_MTurkerMessage.html';
            $("a[class='ErrorInfo']").attr('href', erlink).show();
            $('#WorkerID').html("Recorded Worker ID:   " + query.worker_id);
            $('#AssignmentID').html("Recorded Assignment ID:   " + query.assignment_id);
            $('.wrap_Consent').show();
            $('.wrap_ChooseAvatar').html(' ').hide();
            $('.wrap_Practice').html(' ').hide();
            $('.wrap_Learn').html(' ').hide();
            $('.wrap_Choose').html(' ').hide();
            break;
        case "ChooseAvatar":
            $('.wrap_Consent').html(' ').hide();
            $('.wrap_ChooseAvatar').show();
            $('.wrap_Practice').html(' ').hide();
            $('.wrap_Learn').html(' ').hide();
            $('.wrap_Choose').html(' ').hide();
            break;
        case "Practice":
            $('.wrap_Consent').html(' ').hide();
            $('.wrap_ChooseAvatar').html(' ').hide();
            $('.wrap_Practice').show();
            $('.wrap_Learn').html(' ').hide();
            $('.wrap_Choose').html(' ').hide();
            break;
        case "Learn":
            $('.wrap_Consent').html(' ').hide();
            $('.wrap_ChooseAvatar').html(' ').hide();
            $('.wrap_Practice').html(' ').hide();
            $('.wrap_Learn').show();
            $('.wrap_Choose').html(' ').hide();
            break;
        case "Choice":
            $('.wrap_Consent').html(' ').hide();
            $('.wrap_ChooseAvatar').html(' ').hide();
            $('.wrap_Practice').html(' ').hide();
            $('.wrap_Learn').html(' ').hide();
            $('.wrap_Choose').show();
            break;
    }
};
function doCheck(stage) {                   // Comprehension checks
    var fields = $(":input").serializeArray(),
        nextlink = [],
        hitdetails = "worker_id=" + query.worker_id  + "&assignment_id=" + query.assignment_id  + "&hit_id=" +  query.hit_id;

    switch (stage) {
        case 'Consent':
            nextlink='h1_Instructions.html?' + hitdetails + '&Session=Practice';
            if (fields.length == 2 && fields[0].name == "q0_consent" && fields[1].name == "q1_consent") {
                $("a[class='LinkNextSession']").attr('href', nextlink).show();
                $('.CheckFeedback').html("<p style='color: darkblue; text-align:center'><b>Click the link below to continue with the instructions</b></p>").css({"text-color": "#1D1FA7" }).show();
                break;
            }
            else {
                $('.CheckFeedback').html("<p style='color: #910300; text-align:center'><b>Please tick both boxes to continue</b></p>").show()
                break;
            }
        case 'ChooseAvatar':
            nextlink='h1_Instructions.html?' + hitdetails + '&Session=Practice';
            if (fields.length == 1) {
                $("a[class='LinkNextSession']").attr('href', nextlink).show();
                $('.CheckFeedback').html("<p style='color: darkblue; text-align:center'><b>Click the link below to continue with the instructions</b></p>").css({"text-color": "#1D1FA7" }).show();
                break;
            }
            else {
                $('.CheckFeedback').html("<p style='color: #910300; text-align:center'><b>Please select ONE animal to continue</b></p>").show()
                break;
            }
        case 'Learn':
            nextlink='h2_Learn.html?' + hitdetails;
            if (fields.length==3 && fields[0].name=="q2_3" && fields[1].name=="q2_4" && fields[2].name=="q2_5" ) {
                $('.CheckFeedback').html("<p style='color: darkblue; text-align:center'><b>Well done! <br> Click the link below to start the next session</b></p>").css({"text-color": "#1D1FA7" }).show();
                $("a[class='LinkNextSession']").attr('href', nextlink).show();
                break;
            }
            else {
                $('.CheckFeedback').html("<p style='color: #910300; text-align:center'><b>Incorrect! Try again<br>Feel free to re-read the instructions if you need to</b></p>").show()
                break;
            }
        case 'Choose':
            nextlink='h3_Choose.html?' + hitdetails + '&srcstim=' +  query.srcstim + '&chostim=' +  query.chostim ;
            if (fields.length==3 && fields[0].name=="q3_2" && fields[1].name=="q3_3" && fields[2].name=="q3_5") {
                $('.CheckFeedback').html("<p style='color: darkblue; text-align:center'><b>Well done! <br> Click the link below to start the next session</b></p>").css({"text-color": "#1D1FA7" }).show();
                $("a[class='LinkNextSession']").attr('href', nextlink).show();
                break;
            }
            else {
                $('.CheckFeedback').html("<p style='color: #910300; text-align:center'><b>Incorrect! Try again<br>Feel free to re-read the instructions if you need to</b></p>").show()
                break;
            }
    }
}
function presPracticeTrial(){                   // Practice trials
    $('.StimFeedback').hide();
    $('.InstrucPractice').hide();
    $('.StimQuestion').text(log.Stim.q).css({'font-size': '20pt'}).show();
    $('.StimPres').html('<img src="Stim/Shape/practice_stim' + String(dp_stim1[pn]) + '.bmp" width=log.Stim.size[0]>')
        .css({ "position": "fixed", "top":"40%", 'left':'50%'}).show();

    $(document).on('keydown.askprac', function (event) {
        switch (event.keyCode) {
            case log.key.yes:
                dp_choice[pn]=1;
                break;
            case log.key.no:
                dp_choice[pn]=0;
                break;
        }

        if (dp_choice[pn] > -0.5 && dp_choice[pn] < 1.5) {  // If response is OK
            $(document).off('keydown.askprac');
            $('.StimResponses').text(opFmat(['No','Yes'], dp_choice[pn]))
                .css({'font-size': '1.5em','position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
                .show();
            setTimeout(function () {

                // Feedback
                $('.StimQuestion').hide()
                $('.StimPres').hide();
                $('.StimResponses').hide();
                $('.StimFeedback').html('You were ' + opFmat(['wrong', 'correct'], dp_acc[pn]) + '!')
                    .css({'font-weight':'bold', 'position': 'fixed', 'top': '45%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
                    .show();

                // Continue
                setTimeout(function () {
                    if (pn==log.ntrials_practice-1) { // Instructions for Learning stage
                        $('.InstrucPractice').hide();
                        $('.StimQuestion').hide();
                        $('.StimPres').hide();
                        $('.StimResponses').hide();
                        $('.StimFeedback').hide();

                        $("a[class='LinkNextSession']").attr('href', 'h1_Instructions.html?' + "worker_id=" + query.worker_id  + "&assignment_id=" + query.assignment_id  + "&hit_id=" +  query.hit_id
                            + '&Session=Learn')
                            .css({"position": "fixed",'left':'50%','top':'50%'})
                            .show();
                    }
                    else {
                        pn++;
                        presPracticeTrial();
                    }
                }, 1000);


            }, 500);
        }
    })
}

// [3] Experiment execution ########################################
$(document).ready(doInstruc); // Start the mother