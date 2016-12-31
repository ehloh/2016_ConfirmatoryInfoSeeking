/**
 * Acquisition script for CIS: Session 2 (Learn)
 */

// [1] Set up session  ########################################
var DeveloperMode= 1,           // Am I debugging?
    DeveloperAutoChoice= 1,     // Automatically generate choices
    DeveloperSpeedUp = 1,
    DeveloperMsg=1;
{
    //if (DeveloperMode==1) { console.log('URL par manually added '); var urladd='?worker_id=HC_wid&assignment_aid=HC_aid&hit_id=HC_hid' ; window.history.pushState({'page_id': 1, 'user_id': 5}, 'blah', 'h2_Learn.html' + urladd); }
    var query = opGetQueryParams(document.location.search);
} // Inputs for script running during setup

// Set up Learning session // ###########################################
{
    // Design settings ////////////////////////////////////////////////
    if (DeveloperMode==0) {DeveloperAutoChoice=0; DeveloperMsg=0; DeveloperSpeedUp=0; }
    log.ntrials_infotype = 88;  // WARNING: If you are changing n trials, check effective src accuracy/agreement
                               //   (a) Overall src acc/agree for C/D/N/I will change slightly. Are values acceptable?
                               //   (b) Extent of confirmatoriness will change. New vals (and diffs) acceptable?

    //if (DeveloperMode) { log.ntrials_infotype = 32; pr('FAKE N info trials!!!!') }
    //if (DeveloperMode) { log.Stim.maxno = 500; pr('FAKE stim set  !!!!')}


    log.nblks_infotype = 4;
    log.ntrials_catch = 0;
    log.ntrials = log.ntrials_infotype * 4 + log.ntrials_catch;
    log.nrep_pair_2afc = 1;  // How many times to repeat each pair in each time we test the 2AFC?

    // 2AFC qs (how is learning progressing, w each block?
    log.afc_qs = [ 'similar to you'];
    log.afc_nq = log.afc_qs.length;


    // Catch items
    log.catch_qs =[  // True/false questions
        'You just guessed that the object IS a blap',              // Subject guess
        'You just guessed that the object IS NOT a blap',
        'The other player guessed that the object IS a blap',            // Info/Source said
        'The other player guessed that the object IS NOT a blap',
        'The other player that you just heard from was the BIRD',        // Which source
        'The other player that you just heard from was the CAT',
        'The other player that you just heard from was the ELEPHANT',
        'The other player that you just heard from was the FISH',
        'The guess you made was CORRECT',                          // Subject accuracy
        'The guess you made was WRONG',
        'The guess that the other player made was CORRECT',             // Source accuracy
        'The guess that the other player made was WRONG'
    ];
    log.catch_nq = log.catch_qs.length/2; // Each subject gets asked half the Qs

    // Stimuli
    log.srcstim = shuffle(log.Src.stim_options);  // Source allocation:  C, D, N, I
    log.avatar = opIndexReadVec(log.srcstim, [4,5,6,7]);
    log.srcstim= opIndexReadVec(log.srcstim, [0,1,2,3]);
    log.stimset = shuffle(opLinspace(1,log.Stim.maxno+1,log.Stim.maxno));
    console.log(log.Stim.maxno-(log.ntrials) + ' stim left for choice stage' + '(' + (log.Stim.maxno-(log.ntrials))/6 + ' per src pair)')

    // Timing
    if (DeveloperSpeedUp) {
        log.Stim.time = 200;
        log.time =  {
            Fixation: 1,
            Ask: 1,
            AfterAsk: 50,
            InfoEvent: 1,
            OutcomeEvent: 1};
    } else {
        log.time = {
            Fixation: 1500,
            Ask: 15000,         // 15s as a stand in for infinite
            AfterAsk: 1000,     // After free timed choice
            InfoEvent: 2000,
            OutcomeEvent: 2000
        };
    }

    // Others
    log.key.options = ['No', 'Yes'];
    log.job = {
        hit_id: query.hit_id,
        worker_id: query.worker_id,
        assignment_id: query.assignment_id,
        Session: 'Learn',
        DeveloperMode: DeveloperMode,
        URL_pars: query,
        timestamp: {}
    };
}  // Design settings
{
    // Trial events  ////////////////////////////////////////////////
    var d_stim1 = opIndexReadVec(log.stimset, opLinFromTo(0, log.ntrials-1,1)),
        d_source = new Array(log.ntrials).fill(999),
        d_choice = new Array(log.ntrials).fill(999),
        d_rt = new Array(log.ntrials).fill(999),
        d_info = new Array(log.ntrials).fill(999),
        d_srcacc = new Array(log.ntrials).fill(999),
        d_srcagree= new Array(log.ntrials).fill(999),
        d_outcome = new Array(log.ntrials).fill(999),
        d_trialnum= new Array(log.ntrials).fill(999),
        dc_choice= new Array(log.catch_nq).fill(999),     // Catch question items
        dc_q = opIndexReadVec(shuffle(opLinFromTo(1, log.catch_qs.length,1)), opLinFromTo(0,log.catch_nq-1,1)),  // Sample requested subset of Qs
        dc_trial =opIndexReadVec(shuffle(opLinFromTo(2,log.ntrials-3,1)), opLinFromTo(0,log.catch_nq-1,1)).sort(function(a, b){return a-b});
        d_truth = new Array(log.ntrials).fill(999),  // This is a dummy variable for implementation
        d_block = new Array(log.ntrials).fill(999),   // Dummy variable for implementation
        w = [],
        ws = [],
        bn=0;  // Working variables
    var df_q= new Array(log.afc_nq*6*log.nblks_infotype).fill(999),         // 2AFC: Which Q being asked?
        df_srcpair = new Array(log.afc_nq*6*log.nblks_infotype).fill(999),  // 2AFC: Src Pair
        df_cho = new Array(log.afc_nq*6*log.nblks_infotype).fill(999),      // 2AFC: Cho Src
        df_blk = new Array(log.afc_nq*6*log.nblks_infotype).fill(999),    // 2AFC: After which block did this run?
        qcolors = ['#ffb039', '#ff9886', '#8b816c', '#309245', '#6061ff', '#5cdc67', '#C5CF3F', '#B82AB8', '#38B2B8', '#806bb8'], // Colors for question
        wf=[];

    // Assemble blocks
    console.log('COMPILING DESIGN --------------- ');
    w.blockorder =   shuffle([1,2,3,4]).concat(shuffle([1,2,3,4])).concat(shuffle([1,2,3,4]).concat(shuffle([1,2,3,4]))); // Hard coded for n blocks
    //if (DeveloperMode) { w.blockorder=opVecRepmat([1,2,3,4], log.nblks_infotype); pr('Fake block order'); }
    w.blk_ntrials = log.ntrials_infotype/log.nblks_infotype;
    w.blk_starttrial =  opLinspace(0, log.ntrials, 4*log.nblks_infotype);
    if (w.blk_ntrials%2 >0) {console.log('WARNING: trials per block not evenly divisible by 2. Src agreement/acc will be wrong!')}
    for (var  sr = 1; sr < 5; sr++) {
         // Settings for source
         ws.acc_subcorr = log.pCorrect[ log.Src.condition[sr - 1]][1];
         ws.acc_subwrong = log.pCorrect[log.Src.condition[sr - 1]][0];
         ws.blk_vec =  new Array(w.blk_ntrials).fill(999);
         ws.blk_halfvec = new Array(w.blk_ntrials/2).fill(999);

        //pr('Source ' + sr + ' ---- ' )
        //pr('Acc: '+ opMean(log.pCorrect[ log.Src.condition[sr - 1]]) + '  (' + ws.acc_subcorr +'-' + ws.acc_subwrong +')'  )
        for (var  rn = 0; rn <log.nblks_infotype; rn++) {
             var bn  = opFmat( opNumFindInd(w.blockorder, sr), rn);
             var wb = {
                 t_start: w.blk_starttrial[bn],
                 t_end: w.blk_starttrial[bn] + w.blk_ntrials - 1
             };
            //pr('Rep #' + rn + ': blk ' + bn);

             // Trial numbers within block, shuffle subject right/wrong
             wb.tn_inblock = shuffle(opLinFromTo(wb.t_start, wb.t_end, 1));
             wb.sc_tns  = opIndexReadVec(wb.tn_inblock, opLinFromTo(0, (w.blk_ntrials/2) - 1, 1));
             wb.sw_tns = opIndexReadVec(wb.tn_inblock, opLinFromTo(wb.tn_inblock.length/2, wb.tn_inblock.length-1, 1));
             //
             d_source = opIndexWriteVec(d_source, wb.tn_inblock, ws.blk_vec.fill(sr));
             d_block  = opIndexWriteVec(d_block , wb.tn_inblock, ws.blk_vec.fill(bn));
             d_outcome = opIndexWriteVec(d_outcome, wb.sc_tns, ws.blk_halfvec.fill(1));
             d_outcome = opIndexWriteVec(d_outcome, wb.sw_tns, ws.blk_halfvec.fill(0));

             // Source accuracies
             if (sr < 2.5) { // Confirmatory and Disconfirmatory sources

                 // Fill in subject-correct trials
                 wb.sc_srcacc = shuffle(  opLinspace(0, 1, w.blk_ntrials/2).map(s => +(s < ws.acc_subcorr)));
                 d_srcacc = opIndexWriteVec(d_srcacc, wb.sc_tns, wb.sc_srcacc);

                 // Fill in subject-wrong trials
                 wb.sw_srcacc = shuffle(opLinspace(0, 1, w.blk_ntrials/2).map(s => +(s < ws.acc_subwrong)));
                 d_srcacc = opIndexWriteVec(d_srcacc, wb.sw_tns, wb.sw_srcacc);
             }
             else if (sr == 3) {  // Neutral source

                 // Fetch effective accuracies of the C and D sources
                 wb.smp_tn =  opNumFindInd(d_block, opFmat( opNumFindInd(w.blockorder, 1), 0)); // Trials to sample = 1 block of the C source
                 wb.smp_outcome = opIndexReadVec(d_outcome, wb.smp_tn);
                 wb.smp_srcacc = opIndexReadVec(d_srcacc, wb.smp_tn);

                // Source accuracies for Neutral source
                 if (rn==0) {
                     wb.sc_srcacc = shuffle(opVecRepmat(0, Math.floor(opNumFindInd(wb.smp_srcacc,0).length/2)).concat(opVecRepmat(1, Math.ceil(opNumFindInd(wb.smp_srcacc,1).length/2))));
                 }
                 else {
                     wb.sc_srcacc = shuffle(opVecRepmat(0, Math.ceil(opNumFindInd(wb.smp_srcacc,0).length/2)).concat(opVecRepmat(1, Math.floor(opNumFindInd(wb.smp_srcacc,1).length/2))));
                 }
                 d_srcacc = opIndexWriteVec(d_srcacc, wb.sc_tns, wb.sc_srcacc);
                 d_srcacc = opIndexWriteVec(d_srcacc, wb.sw_tns, shuffle(wb.sc_srcacc));   // Equal accuracies for subj corr/wrong
             }
             else if (sr == 4) { // Inaccurate source
                 if (wb.sc_tns.length != wb.sw_tns.length) {pr('WARNING: n trials not workable for Inaccurate source')}
                 if (rn%2 ==0) {
                     d_srcacc = opIndexWriteVec(d_srcacc, wb.sc_tns, shuffle( opVecRepmat(1, Math.floor(wb.sc_tns.length/2)).concat(opVecRepmat(0, Math.ceil(wb.sc_tns.length/2))) ));
                     d_srcacc = opIndexWriteVec(d_srcacc, wb.sw_tns, shuffle( opVecRepmat(1, Math.floor(wb.sc_tns.length/2)).concat(opVecRepmat(0, Math.ceil(wb.sc_tns.length/2))) ));
                 }
                 else {
                     d_srcacc = opIndexWriteVec(d_srcacc, wb.sc_tns, shuffle( opVecRepmat(0, Math.floor(wb.sc_tns.length/2)).concat(opVecRepmat(1, Math.ceil(wb.sc_tns.length/2))) ));
                     d_srcacc = opIndexWriteVec(d_srcacc, wb.sw_tns, shuffle( opVecRepmat(0, Math.floor(wb.sc_tns.length/2)).concat(opVecRepmat(1, Math.ceil(wb.sc_tns.length/2))) ));
                 }
             }
             // Print design
             wb = [];
         }

        // Source stats
         ws.src_tn = opNumFindInd(d_source, sr);
         for (var t = 0; t <ws.src_tn.length; t++) {
             d_srcagree[ws.src_tn[t]] = d_outcome[ws.src_tn[t]] == d_srcacc[ws.src_tn[t]];
        }     // Theoretical source agreement ( debugging only )
        ws.outcome = opIndexReadVec(d_outcome, ws.src_tn );
        ws.srcacc = opIndexReadVec(d_srcacc, ws.src_tn );
        ws.sc_tn = opIndexReadVec(ws.src_tn, opNumFindInd(ws.outcome, 1));
        ws.sw_tn = opIndexReadVec(ws.src_tn, opNumFindInd(ws.outcome, 0));
        ws.sc_srcacc = opIndexReadVec(d_srcacc, opIndexReadVec(ws.src_tn, opNumFindInd(ws.outcome, 1)));
        ws.sw_srcacc = opIndexReadVec(d_srcacc, opIndexReadVec(ws.src_tn, opNumFindInd(ws.outcome, 0)));

        // Print design
        //pr('B' + bn + ':  ' + log.Src.condition[sr - 1] + '.  Theor acc when sub correct, wrong: ' + ws.acc_subcorr.toFixed(3) + ', ' + ws.acc_subwrong.toFixed(3) + '       [ Overall src acc (theor) = '  + ((ws.acc_subcorr + ws.acc_subwrong)/2).toFixed(3) + ' ]'   )
        //pr('          Effec src acc when sub right, wrong: ' + opMean(opIndexReadVec(d_srcacc, ws.sc_tn)).toFixed(3) + ', ' + opMean(opIndexReadVec(d_srcacc, ws.sw_tn)).toFixed(3) + '       [ Overall src acc (effec) = ' + opMean(opIndexReadVec(d_srcacc, ws.sc_tn.concat(ws.sw_tn))).toFixed(3) + ' ]' )
        ////pr('            [Effec Acc:  Sub = ' + opMean(opIndexReadVec(d_outcome, ws.src_tn)).toFixed(3) + ', Src = ' + opMean(opIndexReadVec(d_srcacc, ws.src_tn)).toFixed(3) + ']')
        // pr('         Effec src AGREE when sub right, wrong: ' + opMean(opIndexReadVec(d_srcagree, ws.sc_tn)).toFixed(3) + ', ' + opMean(opIndexReadVec(d_srcagree, ws.sw_tn)).toFixed(3) + '    [ Overall src agree (effec) = ' + opMean(opIndexReadVec(d_srcagree, ws.sc_tn.concat(ws.sw_tn))).toFixed(3) + ' ]' )


         pr(' ');
        ws=[];
    }
    if ( (typeof d_outcome.indexOf(999) =='undefined') || (d_outcome.indexOf(999) !==-1) )  {console.log('WARNING: Some outcome vals not filled out')}
    if ( (typeof d_srcacc.indexOf(999) =='undefined') || (d_srcacc.indexOf(999) !==-1) )  {console.log('WARNING: Some src-agree vals not filled out')}

    // 2AFC measures
    log.srcpair_src = [[1,2], [1,3], [1,4], [2,3], [2,4],[3,4]];  // 7 is temporarily catch trials
    ws.afc_blks = opLinFromTo(4,4*log.nblks_infotype+1, 4);
    for (var bl= 0; bl < log.nblks_infotype; bl++ ) {   // For each group of 4 blocks
        wf.bl_tstart = bl*log.afc_qs.length*6;
        wf.bl_tend = (bl+1)*log.afc_qs.length*6-1;
        df_blk = opIndexWriteVec(df_blk, opLinFromTo(wf.bl_tstart, wf.bl_tend, 1), opVecRepmat(ws.afc_blks[bl], log.afc_qs.length*6));
        wf.afc_qs =  shuffle(opLinFromTo(1, log.afc_qs.length, 1));
        //pr('BLK ' + bl + ' --------------' )

        for (var q = 0; q < log.afc_qs.length; q++ ) {   // For each Q
            wf.q_tstart = wf.bl_tstart +  (q*6);
            wf.q_tend = wf.bl_tstart +  (q+1)*6 -1;
            df_q = opIndexWriteVec(df_q, opLinFromTo(wf.q_tstart, wf.q_tend, 1), opVecRepmat(wf.afc_qs[q], 6));
            df_srcpair = opIndexWriteVec(df_srcpair, opLinFromTo(wf.q_tstart, wf.q_tend, 1), shuffle([1, 2, 3, 4, 5, 6]));
            //pr('Q' + q + ':   ' + wf.q_tstart + '   -     ' + wf.q_tend )
        }
    }

    // FAKE
    //if (DeveloperMode==1) {dc_trial=[3,6,9,12,14,16];    pr('FAKE dc trials') }

     // Working variables
     for (var i= 0; i< dc_trial.length; i++ ) {  // Catch questions should not be the last of each block
         if (d_source[dc_trial[i]] != d_source[dc_trial[i]+1]) {dc_trial[i]--;}
     }
     var wt={},
        tn= 0,  // Trial number
        cn= 0,  // Catch q
        fn= 0,  // 2AFC trial number
        pn=0;
}  // Trialstats settings

// [2] Event functions ########################################
function presFixation(){
    $('.Fixation').show();
    $('.StimQuestion').text(log.Stim.q).show();
    $('.Ask1').show();
    $(".Info").text(' ').hide();
    $('.StimMask').hide();

    // Set up trial
    d_trialnum[tn] = tn+1;
    $('.StimPres').html('<img src="Stim/Shape/stim' + String(d_stim1[tn]) + '.bmp">').hide();
    if (d_source[tn]>0) {
        wt.pic_name = log.srcstim[d_source[tn]-1];
        $('.SourceStim').html('<img src="Stim/src_' + log.srcstim[d_source[tn]-1] + '.png" height="' + String(log.SrcSize) + 'px" width="' + String(log.SrcSize) + 'px" alt =' + wt.pic_name + ' >').hide()  // <--- This works
    }

    // Display
    presTrialStatsPrint(1);
    if (DeveloperMode==2){   // Press any key to continue. Comment out for testing
        $(document).on('keydown.continue', function(event) {
            $(document).off('keydown.continue');

            setTimeout(function() {   // COPIED FROM BELOW
                $('.Fixation').hide()
                presStim()
                }, log.time.Fixation);
        })
    }
    else {
        setTimeout(function() {
            $('.Fixation').hide()
            presStim()
        }, log.time.Fixation);
    };
}
function presStim(){
    $('.StimPres').show();

    setTimeout(function() {
        presAsk1()
    }, log.Stim.time);
}
function presAsk1() {
    $('.Ask1').show();
    wt.ask1_start = new Date();

    if (DeveloperAutoChoice==1) {
        if (DeveloperSpeedUp) { wt.waifakekey =1} else {wt.waifakekey =1700}
        setTimeout(function () {
            d_choice[tn]= Math.round(Math.random());

            //   COPIED FROM BELOW ----
            if (d_choice[tn] > -0.5 && d_choice[tn] < 1.5) {  // If response is OK
                $('.Ask1').hide();
                $('.AskAns').text(opFmat(['No','Yes'], d_choice[tn]))
                    .css({'position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
                    .show();

                // Continue with trials
                setTimeout(function () {
                    $('.StimMask').hide();
                    $('.Ask1').hide();
                    presaskConfidence()
                }, log.time.AfterAsk);
            }
        }, wt.waifakekey);
    }
    else {
        $(document).on('keydown.ask1', function (event) {
            wt.ask1_keydown = new Date();
            switch (event.keyCode) {
                case log.key.yes:
                    d_choice[tn]=1;
                    break;
                case log.key.no:
                    d_choice[tn]=0;
                    break;
                default:
                    d_choice[tn] = 999;
                    d_rt[tn] = 999;
            }

            if (d_choice[tn] > -0.5 && d_choice[tn] < 1.5) {  // If response is OK
                $(document).off('keydown.ask1');
                $('.Ask1').hide();
                $('.AskAns').text(opFmat(['No','Yes'], d_choice[tn]))
                    .css({'position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
                    .show();

                // Process the recorded response
                d_rt[tn] = opGetRT(wt.ask1_start, wt.ask1_keydown);

                // Continue with trials
                setTimeout(function () {
                    $('.StimMask').hide();
                    $('.Ask1').hide();
                    presaskConfidence()
                }, log.time.AfterAsk);
            }
        })
    }
}
function presaskConfidence() {
    //$('.AskConfidence').show();

    // Assign Information
    d_truth[tn] =  opFmat([Math.abs(1- d_choice[tn]), d_choice[tn]], d_outcome[tn]);
    d_info[tn] =  opFmat([Math.abs( 1- d_truth[tn]), d_truth[tn]], d_srcacc[tn]);

    if (DeveloperAutoChoice==1) {
        setTimeout(function () {
            //d_confidence[tn] = Math.ceil(Math.random()*3);
            wt.confidence = 3;

            // COPIED FROM BELOW
            if (wt.confidence  > 0.5 && wt.confidence  < 3.5) {
                $(document).off('keydown.askconfidence1');
                setTimeout(function () {
                    $('.AskConfidence').hide();
                    if (d_source[tn] > 0.5 && d_source[tn] < 4.5) { // Info trial
                        presInfo(d_info[tn], d_source[tn])
                    }
                    else {
                        $(".Info").text(' ');
                        presOutcomeOK();
                    }

                }, log.time.AfterAsk);
            }
        }, 0);
    }
    else {
        wt.confidence = 3;
        if (wt.confidence  > 0.5 && wt.confidence  < 3.5) {
            $(document).off('keydown.askconfidence1');
            setTimeout(function () {
                $('.AskConfidence').hide();
                if (d_source[tn] > 0.5 && d_source[tn] < 4.5) { // Info trial
                    presInfo(d_info[tn], d_source[tn])
                }
                else {
                    $(".Info").text(' ');
                    presOutcomeOK();
                }

            }, log.time.AfterAsk);
        }
    }
}
function presInfo(info, infosource) {
    $('.StimPres').hide();
    $('.SourceStim').show();
    d_srcagree[tn] = +(d_choice[tn]==d_info[tn]);

    setTimeout(function() {
        $(".Info").text(opFmat(['No', 'Yes'],info)).show();
    }, Math.round(log.time.InfoEvent/3));
    setTimeout(function() {
        $('.Info').hide()
        $('.SourceStim').hide()
        presOutcomeOK()
    }, log.time.InfoEvent);
}
function presOutcomeOK() {
    switch (d_outcome[tn]) {
        case 1:
            $('.Outcome').text('You were correct!')
                .css({'position': 'fixed', 'top': '55%', 'left': '50%', 'transform': 'translate(-50%, -50%)'});
            //$('.Outcome').text('+ ' + log.RewardMag.toString() + ' points').css({'background-color': '#0C5707'});    // Win = green
            break;
        case 0:
            $('.Outcome').text('You were wrong!')
                .css({'position': 'fixed', 'top': '55%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
            //$('.Outcome').text('- ' + log.RewardMag.toString() + ' points').css({'background-color': '#CF0D00'});    // Lose = Red
            break;
    }
    $('.StimQuestion').hide();
    $('.AskAns').hide();
    $(".Outcome").show();
    setTimeout(function() {
        $(".Outcome").hide()
        $(".Info").hide();
        $('.AskAns').text(' ').hide();
        opEndTrial()
        }, log.time.OutcomeEvent);
}
function presOutcomeError() {
    $(".Outcome").text('ERROR').css({'background-color': '#727079'});

    presTrialStatsPrint(2) // Print stats
    setTimeout(function() {
        $(".Outcome").hide()
        opEndTrial()
    }, log.time.OutcomeEvent);
}
function presCatchQ() {
    $(".Catch").html("<br><br><br>Is the statement below (about the trial you just completed) true or false?<br><br><br><br><br><br>" +
            '<b>' + log.catch_qs[dc_q[cn]-1] + '</b><br><br><br><br><br><br>' +
            "Press the UP arrow for TRUE, and the DOWN arrow for FALSE")
        .css({'font-size': '0.8em'})
        .show();
    if (DeveloperAutoChoice==1) {
        if (DeveloperSpeedUp) { wt.waifakekey =2} else {wt.waifakekey =4700}
        setTimeout(function () {
            dc_choice[cn]= Math.round(Math.random());
            //pr('Catch no ' + cn + ' response:  ' + dc_choice[cn])
            cn++;
            tn++;

            // Continue with trials
            $(".Catch").hide();
            presFixation();
        }, wt.waifakekey);
    }
    else {
        $(document).on('keydown.askcatch', function (event) {
            wt.askcatch= new Date();
            switch (event.keyCode) {
                case log.key.yes:
                    dc_choice[cn]=1;
                    break;
                case log.key.no:
                    dc_choice[cn]=0;
                    break;
            }
            //pr('Catch no ' + cn + ' response:  ' + dc_choice[cn])
            if (dc_choice[cn]> -0.5 && dc_choice[cn]< 1.5) {  // If response is OK
                $(document).off('keydown.askcatch');
                cn++;
                tn++;

                // Continue with trials
                setTimeout(function () {
                    $(".Catch").hide();
                    presFixation();
                }, log.time.AfterAsk);
            }
        })
    }
}
function pres2afc(){
    $('.wrap_LearnTrial').hide();
    $('.wrap_Learn2AFC').show();

    // Set up 2AFC trial
    wt.src1= log.srcpair_src[df_srcpair[fn]-1][0];
    wt.src2= log.srcpair_src[df_srcpair[fn]-1][1];
    wt.respOK = 0;
    $('.ChooseInfo1').html('<img src="Stim/src_' + log.srcstim[wt.src1-1] + '.png" height="' + String(log.SrcSize) + 'px" width="' + String(log.SrcSize) + 'px" alt =' + log.srcstim[wt.src1-1] + ' >')
        .css({ 'position': 'fixed', 'top': '50%', 'left': '20%', 'transform': 'translate(-50%, -50%)'}).show();
    $('.ChooseInfo2').html('<img src="Stim/src_' + log.srcstim[wt.src2-1] + '.png" height="' + String(log.SrcSize) + 'px" width="' + String(log.SrcSize) + 'px" alt =' + log.srcstim[wt.src2-1] + ' >')
        .css({ 'position': 'fixed', 'top': '50%', 'left': '80%', 'transform': 'translate(-50%, -50%)'}).show();
    if (fn==0) { wt.col = 0 }  else if  (df_q[fn] != df_q[fn-1]) { wt.col++; }  // Sprite colours
    if (log.afc_qs[df_q[fn]-1].indexOf('similar')== -1) { // If this isn't a question about similarity
        $(".ChooseInfoText").html("<br><b>Which player/source do you think is more " + log.afc_qs[df_q[fn]-1] + "?</b> </br></br>" +
            "Use the left and right arrows to respond<br><br><br>")
            .css({'background': qcolors[wt.col],  'top': '10%', 'font-size': '0.8em', 'font-weight': 'normal'}).show();
    }
    else {
        $(".ChooseInfoText").html("<b><br>Which player do you think is more " + log.afc_qs[df_q[fn]-1] + "?</b> </br></br>" +
                "You will win <b>10,000 points</b> for correctly judging which of the 2 players shown below is more similar to you. " +
                "These extra points will contribute a large amount to how much you are paid as a bonus for this experiment<br><br>" +
                "We will figure out which of the other players is more similar to you by comparing the choices that <br>you both made for the same objects<br><br>")
            .css({'background': qcolors[wt.col],  'top': '10%', 'font-size': '0.8em', 'font-weight': 'normal'}).show();
    }
    if (DeveloperMsg==1) {
        $(".DevMsgStart").html("[AFC trial " + fn.toString() + "] <br><br>" +
            "Sources: " + log.srcstim[wt.src1-1] + '    vs      ' + log.srcstim[wt.src2-1] + '   (' + log.Src.condition[wt.src1-1] + ' vs ' + log.Src.condition[wt.src2-1] + ') <br>' +
            "Question: " +  log.afc_qs[df_q[fn]-1] + "<br><br>" +
            "Block just finished: " + log.srcstim[d_source[tn]-1] +  "  (blk no. " +  String(d_block[tn]+1) + ")")
    }  // Developer messages

    // Get response
    if (DeveloperAutoChoice == 1) {
        //// Random choice
        //wt.respOK = 1 + Math.round(Math.random());
        //df_cho[fn] = log.srcpair_src[df_srcpair[fn] - 1][wt.respOK -1];
        //
        //// Always choose the correct answer
        //df_cho[fn] = Math.min(log.srcpair_src[df_srcpair[fn] - 1][0], log.srcpair_src[df_srcpair[fn] - 1][1]);
        //wt.respOK = 1; // wt.respOK doesn't correspond to choice just for trial continuation

        // pCho changes as learning progresses (within subject)
        if (df_blk[fn]< 2*(df_blk.length/6)+1) {  // 1st two block
            wt.respOK = 1 + Math.round(Math.random());
            df_cho[fn] = log.srcpair_src[df_srcpair[fn] - 1][wt.respOK -1];
        }
        else {
            df_cho[fn] = Math.min(log.srcpair_src[df_srcpair[fn] - 1][0], log.srcpair_src[df_srcpair[fn] - 1][1]);
            wt.respOK = 1; // wt.respOK doesn't correspond to choice just for trial continuation
        }


        // pCorrect (probabilistically, across subjects) increases as trial no. increases
        df_cho[fn] = Math.min(log.srcpair_src[df_srcpair[fn] - 1][0], log.srcpair_src[df_srcpair[fn] - 1][1]);  // Correct answer
        wt.respOK = 1; // wt.respOK doesn't correspond to choice just for trial continuation
        if (Math.random() >  tn/d_choice.length) { // Probabililstically change to a random answer
            wt.respOK = 1 + Math.round(Math.random());
            df_cho[fn] = log.srcpair_src[df_srcpair[fn] - 1][wt.respOK -1];
        }

        setTimeout(function () {
            // COPIED FROM BELOW  #########################################
            if (wt.respOK > 0.5) {  // If response is OK
                $(document).off('keydown.askafc');
                $(".ChooseInfoText").html(' ').show();
                $(".ChooseInfo1").html(' ').show();
                $(".ChooseInfo2").html(' ').show();

                // Message
                if (DeveloperMsg == 1) {
                    $(".DevMsgEnd").html("[AFC trial " + fn.toString() + "] <br><br>" +
                        "Sources: " + log.srcstim[wt.src1 - 1] + '    vs      ' + log.srcstim[wt.src2 - 1] + '   (' + log.Src.condition[wt.src1 - 1] + ' vs ' + log.Src.condition[wt.src2 - 1] + ') <br>' +
                        "Question: " + log.afc_qs[df_q[fn] - 1] + "<br><br>" +
                        "Chose:   " + log.srcstim[df_cho[fn] - 1] + "    (" + opFmat(['Left', 'Right'], wt.respOK - 1) + ")")
                }

                //pr('[Last task trial = ' + tn + '] AFC trial ' + fn);

                // Continue with trials
                setTimeout(function () {
                    if (fn == df_blk.length - 1) {           // END of last AFC block
                        //pr('              END OF LAST AFC BLOCK');
                        $('.wrap_LearnTrial').hide();
                        $('.wrap_Learn2AFC').hide();
                        opPostData();
                    }
                    else if (df_blk[fn] != df_blk[fn + 1]) {   // End of this AFC block
                        fn++;
                        tn++;
                        $('.wrap_LearnTrial').show();
                        $('.wrap_Learn2AFC').hide();
                        //pr('              CONTINUE MAIN TASK (Next: tn= ' + tn + ', bn= ' + fn + ')')
                        presBreakScreen()
                    }
                    else {                                  // More AFC trials
                        fn++;
                        //pr('            Next AFC trial: ' + fn);
                        pres2afc()
                    }
                }, log.time.AfterAsk);
            }
        }, log.time.AfterAsk*20);  // Fake response: wait how long?
    }
    else {
        $(document).on('keydown.askafc', function (event) {
            wt.askafc_keydown = new Date();
            switch (event.keyCode) {
                case log.key.left:
                    df_cho[fn] = log.srcpair_src[df_srcpair[fn] - 1][0];
                    wt.respOK = 1;
                    break;
                case log.key.right:
                    df_cho[fn] = log.srcpair_src[df_srcpair[fn] - 1][1];
                    wt.respOK = 2;
                    break;
            }
            if (wt.respOK > 0.5) {  // If response is OK
                $(document).off('keydown.askafc');
                $(".ChooseInfoText").html(' ').show();
                $(".ChooseInfo1").html(' ').show();
                $(".ChooseInfo2").html(' ').show();

                // Message
                if (DeveloperMsg == 1) {
                    $(".DevMsgEnd").html("[AFC trial " + fn.toString() + "] <br><br>" +
                        "Sources: " + log.srcstim[wt.src1 - 1] + '    vs      ' + log.srcstim[wt.src2 - 1] + '   (' + log.Src.condition[wt.src1 - 1] + ' vs ' + log.Src.condition[wt.src2 - 1] + ') <br>' +
                        "Question: " + log.afc_qs[df_q[fn] - 1] + "<br><br>" +
                        "Chose:   " + log.srcstim[df_cho[fn] - 1] + "    (" + opFmat(['Left', 'Right'], wt.respOK - 1) + ")")
                }
                // Continue with trials
                setTimeout(function () {
                    if (fn == df_blk.length - 1) {           // END of last AFC block
                        $('.wrap_LearnTrial').hide();
                        $('.wrap_Learn2AFC').hide();
                        opPostData();
                    }
                    else if (df_blk[fn] != df_blk[fn + 1]) {   // End of this AFC block
                        fn++;
                        tn++;
                        $('.wrap_LearnTrial').show();
                        $('.wrap_Learn2AFC').hide();
                        presBreakScreen()
                    }
                    else {                                  // More AFC trials
                        fn++;
                        pres2afc()
                    }
                }, log.time.AfterAsk);
            }
        });
    }

}
function presTrialStatsPrint(which) {    //  Print to display, end trial
    // Input: 1=Start, 2=End
    if (DeveloperMsg==1) {
        switch (which) {
            case 1: // Start
                $(".DevMsgStart").html("[Trial " + tn.toString() + "] Source: " + log.srcstim[d_source[tn]-1]  + '   (' + log.Src.condition[d_source[tn]-1] + ') <br><br><br>' +
                    '      Source is :      '  + opFmat(['Wrong', 'Correct'], d_srcacc[tn]) + '<br><br>' +
                    '      Subject is:  ' + opFmat(['Wrong', 'Correct'], d_outcome[tn])).show();
                break;
            case 2:  // End
                $(".DevMsgEnd").html("[Trial " + tn.toString() + "] Source: " + log.srcstim[d_source[tn]-1]  + '  (' + log.Src.condition[d_source[tn]-1] + ') <br><br><br>' +
                    '      Source is :      ' + opFmat(['No', 'Yes'], d_info[tn]) + '    =     '  + opFmat(['Disagree', 'Agree'], d_srcagree[tn])  + '    -    '  + opFmat(['Wrong', 'Correct'], d_srcacc[tn]) + '<br><br>' +
                    '      Subj said :  ' + opFmat(['No', 'Yes'], d_choice[tn]) + '  (' + opFmat(['Wrong', 'Correct'], d_outcome[tn]) + ')').show();
                break;
        }
    }
}
function opEndTrial(){
    presTrialStatsPrint(2);
    //pr('                                ' + (d_block[tn]+1) + '-' + tn)

    if (tn+1== dc_trial[cn])  {  // Catch questions
        presCatchQ()
    }
    else if (tn>1 && d_block[tn+1]!=d_block[tn]) {  // Next-block / End of expt (via 2AFC)
        //pr('[tn ' + tn + '] Finished block ' + (d_block[tn]+1) + ' ---------------- ' + '  (next AFC after block ' + df_blk[fn] + ')');
        //pr('       ( EVAL) Trigger AFC now: ' + ( d_block[tn]+1 == df_blk[fn]));
        if ( d_block[tn]+1 == df_blk[fn]) {  // Run an AFC block ?
            //pr('       ( Action ) Run AFC block');
            pres2afc();  // Implement increments to next block within pres2afc
        }
        else {
            //pr('       ( Action ) Continue next BLOCK' );
            tn++;
            presBreakScreen()
        }
    }
    else {   // Changes here should also be added to the catchQ function
        tn++;
        presFixation()
    }
}
function opPostData(){
    $('.wraps2_Trial').hide();
    log.job.timestamp.end = new Date();
    console.log("TIME TAKEN:  " + String( log.job.timestamp.end.getHours()-log.job.timestamp.start.getHours()) + " hrs " + String(log.job.timestamp.end.getMinutes()- log.job.timestamp.start.getMinutes()) + " minutes")


    // At the end of the day: Are the meta-stats as expected? (DEBUGGING)
    console.log('################################### END ###################################')
    for (var  bn=0; bn < w.blockorder.length; bn++) {
        var wb = {
            t_start: w.blk_starttrial[bn],
            t_end: w.blk_starttrial[bn]+ w.blk_ntrials-1,
            cond: w.blockorder[bn]
            //blk_vec: Array(w.blk_ntrials).fill(999),
            //blk_halfvec: Array(w.blk_ntrials/2).fill(999)
        };

        // Trial numbers within block, shuffle subject right/wrong
        wb.tn_inblock = opLinFromTo(wb.t_start,  wb.t_end,1);
        wb.sc_tns =  new Array(0).fill(999)
        wb.sw_tns = new Array(0).fill(999)
        for (var  tn=0; tn < wb.tn_inblock.length; tn++) {
            switch (d_outcome[wb.tn_inblock[tn]]) {
                case 1:
                    wb.sc_tns.push(wb.tn_inblock[tn]);
                    break;
                case 0:
                    wb.sw_tns.push(wb.tn_inblock[tn]);
                    break;
            }
        }

        // Print design
        console.log('B' + bn + ':  ' + log.Src.condition[wb.cond-1]  + '.')
        console.log('         Effec src acc when sub right, wrong: ' +  opMean(opIndexReadVec(d_srcacc,wb.sc_tns)).toFixed(3) + ', ' +  opMean(opIndexReadVec(d_srcacc,wb.sw_tns)).toFixed(3))
        console.log('            [Acc:  Sub = ' + opMean(opIndexReadVec(d_outcome,wb.tn_inblock)).toFixed(3) + ', Src = ' + opMean(opIndexReadVec(d_srcacc,wb.tn_inblock)).toFixed(3) + ']')
        console.log('         Effec src agree when sub right, wrong: ' +  opMean(opIndexReadVec(d_srcagree,wb.sc_tns)).toFixed(3) + ', ' +  opMean(opIndexReadVec(d_srcagree,wb.sw_tns)).toFixed(3))
        console.log(' ');
        wb=[];
    }

    // Post to Server
    var postdata= markname + "subject" + markeq + log.job.worker_id + marknext
        + markname + "session" + markeq + "1Learn" + marknext
        + markname + "log" + markeq + JSON.stringify(log) + marknext
        + markname + "d_truth" + markeq + d_truth + marknext
        + markname + "d_stim1" + markeq + d_stim1 + marknext
        + markname + "d_source" + markeq + d_source + marknext
        + markname + "d_choice" + markeq + d_choice+ marknext
        + markname + "d_rt" + markeq + d_rt+ marknext
        + markname + "d_info" + markeq + d_info+ marknext
        + markname + "d_srcagree" + markeq + d_srcagree + marknext
        + markname + "d_srcacc" + markeq + d_srcacc + marknext
        + markname + "d_outcome" + markeq + d_outcome + marknext
        + markname + "d_trialnum" + markeq + d_trialnum + marknext
        //+ markname + "d_blocknum" + markeq + d_blocknum + marknext
        + markname + "df_q" + markeq + df_q + marknext                  // 2AFC
        + markname + "df_srcpair" + markeq + df_srcpair + marknext
        + markname + "df_cho" + markeq + df_cho + marknext
        + markname + "df_blk" + markeq + df_blk + marknext
        + markname + "dc_choice" + markeq + dc_choice + marknext
        + markname + "dc_q" + markeq + dc_q + marknext
        + markname + "dc_trial" + markeq + dc_trial + marknext
        + markend;
    $.ajax({
        type: "POST",
        url: "https://experiments.affectivebrain.com/EL/f_submitdata_CIS.php",
        data: { 'data': postdata}
    });

    // Display
    $('.StartEnd_text').html("<b>You are finished with this stage of the experiment! <br> Please feel free to take a break <br><br>" +
        "When you are ready to continue, click on the link below to continue with the next session's instructions</b><br><br><br>"+
        "<p style='font-size: 0.8em'>We've noticed that a small proportion of people have had difficulties with having a consistent internet connection throughout the study." +
        "This means that their data does not get sent to us, and we cannot pay them fully for the HIT<br><br>" +
        "<b>We would like to do our best to pay everyone who makes an honest attempt to do our study.</b>" +
        "Unfortunately, because there are a number of MTurk workers who " +
        "Although we have no control over your internet connection, we'd like to try our best to pay you if you've taken the time to complete our HIT. " +
        "To help us do that, please save the long string of characters shown below (e.g. copy it to a text file on your computer). " +
        "Make sure you save the entire string of text - you might have to zoom out on your browser to see the whole text. " +
        "We will give you instructions about what to do with it later on. <br><br>" +
        "[ START OF TEXT STRING ] <p style='font-size: 0.3em'> " + postdata + "</p> [ END OF TEXT STRING ]</p>")
        .css({ 'width': '800px', 'position': 'fixed', 'top': '40%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
        .show()
    $('.LinkInstruc').show();


    // Post to next session
    var nextlink='h1_Instructions.html?'  // Append details to be passed to next session
        + "worker_id=" + log.job.worker_id + "&assignment_id=" + log.job.assignment_id + "&hit_id=" + log.job.hit_id
        + "&Session=Choice"
        + "&srcstim=" + JSON.stringify(log.srcstim)
        //+ "&srcorder=" +  log.srcstim[0].substr(0,1)+log.srcstim[1].substr(0,1)+log.srcstim[2].substr(0,1)+log.srcstim[3].substr(0,1)
        + "&chostim=" +  JSON.stringify(opIndexReadVec(log.stimset,opLinFromTo(log.ntrials, log.stimset.length-1, 1)));
    $("a[class='LinkInstruc']").attr('href', nextlink).show();



    if (DeveloperMsg) {
        $('.DevMsgEnd').html(
            'Done<br><br>' +
            postdata
        ).show()
    }
}
function presBreakScreen() {
    wt.pic_name = log.srcstim[d_source[tn]-1];
    $('.SourceStim').html('<img src="Stim/src_' + log.srcstim[d_source[tn]-1] + '.png" height="' + String(150) + 'px" width="' + String(150) + 'px" alt =' + wt.pic_name + ' >')
        .show();
    $('.StartEnd_text').html("<br><br><br>Well done! Next, you will learn about the player who is represented by the " + wt.pic_name.toUpperCase() + "<br><br><br><br>"
            + "Please take a break if you like <br><br>"
            + "You have finished " + String(tn-1) + " out of " + String(d_choice.length) + " trials in this session"
            + "<br><br><br><br>Press any key to continue with the experiment")
        .css({ 'position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
        .show();

    // Fake: Waiting for other players to catch up
    wt.fakewait =  +(Math.random()<0.25)*(5+ Math.random()*6)*1000;

    if (DeveloperAutoChoice == 10) {
        if (wt.fakewait>0) {
            $('.StartEnd_text').html('Please wait a few seconds for the other players to catch up<br>' +
                'Estimated wait: No more than 20 seconds');
            $('.SourceStim').hide()
        }
        setTimeout(function () {    // Fake waiting (for other player to catch up
            setTimeout(function () {
                $('.StartEnd_text').text(' ');
                $('.wraps2_Trial').show();
                presFixation()
            }, 1000);  // Continue after 1s
        },wt.fakewait);
    }
else {
    $(document).on('keydown.break', function (event) {
        $(document).off('keydown.break');

        if (wt.fakewait>0) {
            $('.StartEnd_text').html('Please wait a few seconds for the other players to catch up<br>' +
                'Estimated wait: No more than 20 seconds');
            $('.SourceStim').hide()
        }
        setTimeout(function () {    // Fake waiting (for other player to catch up
            setTimeout(function () {
                $('.StartEnd_text').text(' ');
                $('.wraps2_Trial').show();
                presFixation()
            },wt.fakewait);
        }, 1000);  // Continue after 1s
    })
}
}
function presChooseAvatar() {
    // Set up Avatar options
    wt.avn = 0; $('.av1').html('<img src="Stim/src_' + log.avatar[wt.avn] + '_small.png" alt ="' + log.avatar[wt.avn] + '">').show();
    wt.avn = 1; $('.av2').html('<img src="Stim/src_' + log.avatar[wt.avn] + '_small.png" alt =' + log.avatar[wt.avn] + ' >').show();
    wt.avn = 2; $('.av3').html('<img src="Stim/src_' + log.avatar[wt.avn] + '_small.png" alt =' + log.avatar[wt.avn] + ' >').show();
    wt.avn = 3; $('.av4').html('<img src="Stim/src_' + log.avatar[wt.avn] + '_small.png" alt =' + log.avatar[wt.avn] + ' >').show();
    $('.avinstruct').html('Use the keys to select which animal picture you want<br>' +
        '<br>Key 1: &nbsp;&nbsp;&nbsp;&nbsp;' +    log.avatar[0].toUpperCase() +
        '<br>Key 2: &nbsp;&nbsp;&nbsp;&nbsp;' +    log.avatar[1].toUpperCase()  +
        '<br>Key 3: &nbsp;&nbsp;&nbsp;&nbsp;' +    log.avatar[2].toUpperCase()  +
        '<br>Key 4: &nbsp;&nbsp;&nbsp;&nbsp;' +    log.avatar[3].toUpperCase()).show();
    $('.wrap_ChooseAvatar').show();

    $(document).on('keydown.avatar', function(event) {
        $(document).off('keydown.avatar');

        switch (event.keyCode) {
            case log.key.k1:
                log.avatar = opFmat(log.avatar, 0);
                break;
            case log.key.k2:
                log.avatar = opFmat(log.avatar, 1);
                break;
            case log.key.k3:
                log.avatar = opFmat(log.avatar, 2);
                break;
            case log.key.k4:
                log.avatar = opFmat(log.avatar, 3);
                break;
        }

        // Continue w trials
        if (typeof(log.avatar)=='string') {
            $('.wrap_ChooseAvatar').hide();
            goTrial()
        }
    })


}



// [4] Experiment execution ########################################
var goTrial= function() {
    log.job.timestamp.start = new Date();   // Record details

    // Flag: 1st source to learn about
    wt.pic_name = log.srcstim[d_source[tn]-1];
    $('.SourceStim').html('<img src="Stim/src_' + log.srcstim[d_source[tn]-1] + '.png" height="' + String(150) + 'px" width="' + String(150) + 'px" alt =' + wt.pic_name + ' >')
        .show();
    $('.StartEnd_text').html("<br><br><br>First, you will learn about the player who is represented by the " + wt.pic_name.toUpperCase() + "<br><br>"
        + "Get ready!<br><br><br>"
        + "Remember: Press the UP arrow if you think the object is a blap,<br>"
        + "and the DOWN arrow if you think it is NOT a blap")
        .css({ 'position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
        .show();

    if (DeveloperMsg!=1) {
        $('.DevMsgStart').hide();
        $('.DevMsgEnd').hide();
    }
    $('.wrap_Learn2AFC').hide();

    setTimeout(function() {
        $('.StartEnd_text').hide();
        presFixation();
    }, 7000);
};
//$(document).ready(goTrial);



$(document).ready(presChooseAvatar);