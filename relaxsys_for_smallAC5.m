function [t,x,names] = relaxsys_for_smallAC5(obj, simtime)
% -------------------------------------------------------------------------
% 'relaxsys' equilibrates the system by simulating for a given time
% simtime, and sets the steady state values of the concentration for each species as
% the InitialAmount for that species. 
%
% --- Based on a similar script by
%     Omar Gutierrez Arenas while @ Hellgren-Kotaleski Lab 2011-2014 ---
%
      
      all_species = obj.species;
      for i = 1:length(all_species)
         proper_species_names{i} = [all_species(i).parent.name,'.',all_species(i).name];
      end

      cnfst = getconfigset(obj);
      old_stoptime = get(cnfst,'StopTime');
      old_maxstep = get(cnfst.SolverOptions,'MaxStep');
      old_soltyp = get(cnfst,'SolverType');
      old_otptm = get(cnfst.SolverOptions,'OutputTimes');
      
      
      set(cnfst.SolverOptions,'MaxStep', simtime);
      set(cnfst,'StopTime',simtime);
      set(cnfst.SolverOptions, 'OutputTimes',[])
        
      %set(cnfst.SolverOptions,'MaxStep',1e6);
      %set(cnfst, 'StopTime',1e9);
       
      try
           set(cnfst,'SolverType','ode15s')  
           [t,x,names] = sbiosimulate(obj);         
      catch           
           set(cnfst,'SolverType','sundials')         
           [t,x,names] = sbiosimulate(obj);
      end
      
      lead_string = 'Spine.';
      for i=1:length(names)
          names{i} = strcat(lead_string,names{i});
      end
      [result, sp_idx, names_idx] = intersect(proper_species_names,names);
      
      for i = 1:length(sp_idx)
          try
          all_species(sp_idx(i)).InitialAmount = abs(x(end,names_idx(i)));
          catch              
            ['The initial amount of ', proper_species_names{sp_idx(i)},' could not be set by relaxsys']  
                abs(x(end,names_idx(i)))
          end
      end
      
      set(cnfst.SolverOptions,'MaxStep',old_maxstep);
      set(cnfst,'StopTime',old_stoptime);
      
      set(cnfst,'SolverType',old_soltyp);
      set(cnfst.SolverOptions,'OutputTimes',old_otptm);
                             
end