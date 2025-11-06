import React, { useState } from 'react';
import { Globe, Server, Database, Shield, Network, Zap, ArrowRight, Lock, Unlock } from 'lucide-react';

export default function AWSVPCMasterDiagram() {
  const [activeFlow, setActiveFlow] = useState('none');

  return (
    <div className="w-full min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-8 overflow-auto">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-white mb-2">AWS VPC Architecture Master Guide</h1>
          <p className="text-slate-300 text-lg">Complete Visual Guide • Multi-AZ High Availability • Terraform Ready</p>
          <div className="mt-4 inline-block bg-blue-500/20 border border-blue-400 rounded-lg px-6 py-2">
            <span className="text-blue-300 font-mono text-sm">VPC CIDR: 10.0.0.0/16 (65,536 IPs)</span>
          </div>
        </div>

        {/* Interactive Flow Buttons */}
        <div className="flex justify-center gap-4 mb-8">
          <button 
            onClick={() => setActiveFlow('public')}
            className={`px-6 py-3 rounded-lg font-semibold transition ${activeFlow === 'public' ? 'bg-blue-500 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'}`}
          >
            Show Public Flow
          </button>
          <button 
            onClick={() => setActiveFlow('private')}
            className={`px-6 py-3 rounded-lg font-semibold transition ${activeFlow === 'private' ? 'bg-purple-500 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'}`}
          >
            Show Private Flow
          </button>
          <button 
            onClick={() => setActiveFlow('none')}
            className={`px-6 py-3 rounded-lg font-semibold transition ${activeFlow === 'none' ? 'bg-slate-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'}`}
          >
            Reset
          </button>
        </div>

        {/* Main Diagram */}
        <div className="relative bg-slate-800 rounded-xl shadow-2xl p-8 border border-slate-700">
          
          {/* Internet Cloud */}
          <div className="absolute -top-16 left-1/2 transform -translate-x-1/2 flex flex-col items-center z-20">
            <div className={`bg-gradient-to-br from-blue-500 to-blue-600 text-white p-6 rounded-full shadow-2xl transition ${activeFlow !== 'none' ? 'ring-4 ring-blue-400 animate-pulse' : ''}`}>
              <Globe size={40} />
            </div>
            <span className="text-lg font-bold text-white mt-3 bg-slate-800 px-4 py-1 rounded-full">Internet</span>
          </div>

          {/* Arrow from Internet to IGW */}
          <div className={`absolute top-12 left-1/2 transform -translate-x-1/2 transition ${activeFlow !== 'none' ? 'opacity-100' : 'opacity-30'}`}>
            <div className={`w-1 h-12 ${activeFlow !== 'none' ? 'bg-yellow-400' : 'bg-slate-600'}`}></div>
          </div>

          {/* VPC Container */}
          <div className="border-4 border-orange-500 rounded-xl p-8 bg-gradient-to-br from-orange-900/20 to-orange-800/20 backdrop-blur mt-8">
            
            {/* VPC Header */}
            <div className="flex items-center justify-between mb-8 bg-orange-500/20 border border-orange-400 rounded-lg p-4">
              <div className="flex items-center gap-3">
                <Network className="text-orange-400" size={32} />
                <div>
                  <span className="text-2xl font-bold text-orange-300">VPC: 10.0.0.0/16</span>
                  <p className="text-orange-400 text-sm mt-1">Your Isolated Private Cloud Network</p>
                </div>
              </div>
              <div className="text-right">
                <div className="text-orange-300 text-sm">Total Available IPs</div>
                <div className="text-orange-400 font-mono text-xl">65,536</div>
              </div>
            </div>

            {/* Internet Gateway */}
            <div className="flex justify-center mb-8 relative">
              <div className={`bg-gradient-to-r from-blue-600 to-blue-700 text-white px-8 py-4 rounded-lg shadow-xl border-2 transition ${activeFlow !== 'none' ? 'border-yellow-400 shadow-yellow-400/50' : 'border-blue-400'}`}>
                <div className="flex items-center gap-3">
                  <Unlock size={24} />
                  <div>
                    <div className="font-bold text-lg">Internet Gateway (IGW)</div>
                    <div className="text-blue-200 text-sm">VPC's Door to the Internet</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Flow arrows from IGW */}
            <div className="flex justify-center gap-32 mb-6">
              <div className={`flex flex-col items-center transition ${activeFlow === 'public' ? 'opacity-100' : 'opacity-30'}`}>
                <div className={`w-1 h-12 ${activeFlow === 'public' ? 'bg-yellow-400' : 'bg-slate-600'}`}></div>
                <span className={`text-xs font-bold ${activeFlow === 'public' ? 'text-yellow-400' : 'text-slate-500'}`}>DIRECT</span>
              </div>
              <div className={`flex flex-col items-center transition ${activeFlow === 'private' ? 'opacity-100' : 'opacity-30'}`}>
                <div className={`w-1 h-12 ${activeFlow === 'private' ? 'bg-yellow-400' : 'bg-slate-600'}`}></div>
                <span className={`text-xs font-bold ${activeFlow === 'private' ? 'text-yellow-400' : 'text-slate-500'}`}>VIA NAT</span>
              </div>
            </div>

            {/* Two Availability Zones */}
            <div className="grid grid-cols-2 gap-6">
              
              {/* Availability Zone A */}
              <div className="border-3 border-green-500 rounded-xl p-6 bg-gradient-to-br from-green-900/30 to-green-800/20">
                <div className="flex items-center gap-3 mb-6 bg-green-500/20 border border-green-400 rounded-lg p-3">
                  <Shield className="text-green-400" size={24} />
                  <span className="font-bold text-green-300 text-lg">Availability Zone A</span>
                </div>

                {/* Public Subnet A */}
                <div className={`border-3 rounded-lg p-5 mb-5 transition ${activeFlow === 'public' ? 'border-yellow-400 bg-blue-900/40 shadow-lg shadow-yellow-400/30' : 'border-blue-400 bg-blue-900/30'}`}>
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <div className="flex items-center gap-2">
                        <Unlock className="text-blue-400" size={20} />
                        <span className="font-bold text-blue-300 text-lg">Public Subnet A</span>
                      </div>
                      <div className="text-blue-400 text-sm font-mono mt-1">10.0.1.0/24 (256 IPs)</div>
                    </div>
                  </div>
                  
                  {/* NAT Gateway */}
                  <div className={`bg-gradient-to-r from-amber-600 to-amber-700 text-white px-4 py-3 rounded-lg mb-3 border-2 transition ${activeFlow === 'private' ? 'border-yellow-400 shadow-lg shadow-yellow-400/30' : 'border-amber-500'}`}>
                    <div className="flex items-center gap-2">
                      <Zap size={20} />
                      <div>
                        <div className="font-bold">NAT Gateway A</div>
                        <div className="text-amber-200 text-xs">Has Elastic IP (Public)</div>
                      </div>
                    </div>
                  </div>

                  {/* Route Table */}
                  <div className="bg-slate-700 rounded p-3 border border-slate-600">
                    <div className="text-blue-300 font-semibold text-sm mb-2">Route Table (Public-A)</div>
                    <div className="font-mono text-xs space-y-1">
                      <div className="flex items-center gap-2 text-green-400">
                        <span>10.0.0.0/16</span>
                        <ArrowRight size={12} />
                        <span>local</span>
                      </div>
                      <div className="flex items-center gap-2 text-yellow-400">
                        <span>0.0.0.0/0</span>
                        <ArrowRight size={12} />
                        <span className="font-bold">IGW ✓</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Arrow between subnets */}
                <div className="flex justify-center my-3">
                  <div className="flex flex-col items-center">
                    <div className={`w-1 h-6 transition ${activeFlow === 'private' ? 'bg-yellow-400' : 'bg-slate-600'}`}></div>
                    <div className={`px-3 py-1 rounded text-xs font-bold transition ${activeFlow === 'private' ? 'bg-yellow-400 text-slate-900' : 'bg-slate-700 text-slate-400'}`}>
                      USES NAT
                    </div>
                    <div className={`w-1 h-6 transition ${activeFlow === 'private' ? 'bg-yellow-400' : 'bg-slate-600'}`}></div>
                  </div>
                </div>

                {/* Private Subnet A */}
                <div className={`border-3 rounded-lg p-5 transition ${activeFlow === 'private' ? 'border-yellow-400 bg-purple-900/40 shadow-lg shadow-yellow-400/30' : 'border-purple-400 bg-purple-900/30'}`}>
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <div className="flex items-center gap-2">
                        <Lock className="text-purple-400" size={20} />
                        <span className="font-bold text-purple-300 text-lg">Private Subnet A</span>
                      </div>
                      <div className="text-purple-400 text-sm font-mono mt-1">10.0.3.0/24 (256 IPs)</div>
                    </div>
                  </div>

                  {/* Resources */}
                  <div className="space-y-2 mb-3">
                    <div className="bg-purple-600 text-white px-3 py-2 rounded flex items-center gap-2 text-sm">
                      <Database size={16} />
                      <span>RDS Primary</span>
                    </div>
                    <div className="bg-purple-600 text-white px-3 py-2 rounded flex items-center gap-2 text-sm">
                      <Server size={16} />
                      <span>EKS Worker Nodes</span>
                    </div>
                  </div>

                  {/* Route Table */}
                  <div className="bg-slate-700 rounded p-3 border border-slate-600">
                    <div className="text-purple-300 font-semibold text-sm mb-2">Route Table (Private-A)</div>
                    <div className="font-mono text-xs space-y-1">
                      <div className="flex items-center gap-2 text-green-400">
                        <span>10.0.0.0/16</span>
                        <ArrowRight size={12} />
                        <span>local</span>
                      </div>
                      <div className="flex items-center gap-2 text-amber-400">
                        <span>0.0.0.0/0</span>
                        <ArrowRight size={12} />
                        <span className="font-bold">NAT-A ✓</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Availability Zone B - Same structure */}
              <div className="border-3 border-green-500 rounded-xl p-6 bg-gradient-to-br from-green-900/30 to-green-800/20">
                <div className="flex items-center gap-3 mb-6 bg-green-500/20 border border-green-400 rounded-lg p-3">
                  <Shield className="text-green-400" size={24} />
                  <span className="font-bold text-green-300 text-lg">Availability Zone B</span>
                </div>

                {/* Public Subnet B */}
                <div className={`border-3 rounded-lg p-5 mb-5 transition ${activeFlow === 'public' ? 'border-yellow-400 bg-blue-900/40 shadow-lg shadow-yellow-400/30' : 'border-blue-400 bg-blue-900/30'}`}>
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <div className="flex items-center gap-2">
                        <Unlock className="text-blue-400" size={20} />
                        <span className="font-bold text-blue-300 text-lg">Public Subnet B</span>
                      </div>
                      <div className="text-blue-400 text-sm font-mono mt-1">10.0.2.0/24 (256 IPs)</div>
                    </div>
                  </div>
                  
                  {/* NAT Gateway */}
                  <div className={`bg-gradient-to-r from-amber-600 to-amber-700 text-white px-4 py-3 rounded-lg mb-3 border-2 transition ${activeFlow === 'private' ? 'border-yellow-400 shadow-lg shadow-yellow-400/30' : 'border-amber-500'}`}>
                    <div className="flex items-center gap-2">
                      <Zap size={20} />
                      <div>
                        <div className="font-bold">NAT Gateway B</div>
                        <div className="text-amber-200 text-xs">Has Elastic IP (Public)</div>
                      </div>
                    </div>
                  </div>

                  {/* Route Table */}
                  <div className="bg-slate-700 rounded p-3 border border-slate-600">
                    <div className="text-blue-300 font-semibold text-sm mb-2">Route Table (Public-B)</div>
                    <div className="font-mono text-xs space-y-1">
                      <div className="flex items-center gap-2 text-green-400">
                        <span>10.0.0.0/16</span>
                        <ArrowRight size={12} />
                        <span>local</span>
                      </div>
                      <div className="flex items-center gap-2 text-yellow-400">
                        <span>0.0.0.0/0</span>
                        <ArrowRight size={12} />
                        <span className="font-bold">IGW ✓</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Arrow between subnets */}
                <div className="flex justify-center my-3">
                  <div className="flex flex-col items-center">
                    <div className={`w-1 h-6 transition ${activeFlow === 'private' ? 'bg-yellow-400' : 'bg-slate-600'}`}></div>
                    <div className={`px-3 py-1 rounded text-xs font-bold transition ${activeFlow === 'private' ? 'bg-yellow-400 text-slate-900' : 'bg-slate-700 text-slate-400'}`}>
                      USES NAT
                    </div>
                    <div className={`w-1 h-6 transition ${activeFlow === 'private' ? 'bg-yellow-400' : 'bg-slate-600'}`}></div>
                  </div>
                </div>

                {/* Private Subnet B */}
                <div className={`border-3 rounded-lg p-5 transition ${activeFlow === 'private' ? 'border-yellow-400 bg-purple-900/40 shadow-lg shadow-yellow-400/30' : 'border-purple-400 bg-purple-900/30'}`}>
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <div className="flex items-center gap-2">
                        <Lock className="text-purple-400" size={20} />
                        <span className="font-bold text-purple-300 text-lg">Private Subnet B</span>
                      </div>
                      <div className="text-purple-400 text-sm font-mono mt-1">10.0.4.0/24 (256 IPs)</div>
                    </div>
                  </div>

                  {/* Resources */}
                  <div className="space-y-2 mb-3">
                    <div className="bg-purple-600 text-white px-3 py-2 rounded flex items-center gap-2 text-sm">
                      <Database size={16} />
                      <span>RDS Standby</span>
                    </div>
                    <div className="bg-purple-600 text-white px-3 py-2 rounded flex items-center gap-2 text-sm">
                      <Server size={16} />
                      <span>EKS Worker Nodes</span>
                    </div>
                  </div>

                  {/* Route Table */}
                  <div className="bg-slate-700 rounded p-3 border border-slate-600">
                    <div className="text-purple-300 font-semibold text-sm mb-2">Route Table (Private-B)</div>
                    <div className="font-mono text-xs space-y-1">
                      <div className="flex items-center gap-2 text-green-400">
                        <span>10.0.0.0/16</span>
                        <ArrowRight size={12} />
                        <span>local</span>
                      </div>
                      <div className="flex items-center gap-2 text-amber-400">
                        <span>0.0.0.0/0</span>
                        <ArrowRight size={12} />
                        <span className="font-bold">NAT-B ✓</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

            </div>
          </div>

          {/* Traffic Flow Explanation */}
          <div className="mt-8 grid md:grid-cols-2 gap-6">
            <div className="bg-gradient-to-br from-blue-900/50 to-blue-800/30 border-2 border-blue-400 rounded-xl p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="bg-blue-500 p-3 rounded-lg">
                  <Unlock size={24} className="text-white" />
                </div>
                <h3 className="text-xl font-bold text-blue-300">Public Subnet Traffic</h3>
              </div>
              <div className="space-y-3 text-blue-200">
                <div className="flex items-start gap-2">
                  <span className="text-yellow-400 font-bold">→</span>
                  <span>Direct access to Internet Gateway</span>
                </div>
                <div className="flex items-start gap-2">
                  <span className="text-yellow-400 font-bold">→</span>
                  <span>Resources get Public IPs automatically</span>
                </div>
                <div className="flex items-start gap-2">
                  <span className="text-yellow-400 font-bold">→</span>
                  <span>Hosts: Load Balancers, Bastion, NAT Gateway</span>
                </div>
                <div className="flex items-start gap-2">
                  <span className="text-yellow-400 font-bold">→</span>
                  <span>Route: <span className="font-mono text-yellow-400">0.0.0.0/0 → IGW</span></span>
                </div>
              </div>
            </div>

            <div className="bg-gradient-to-br from-purple-900/50 to-purple-800/30 border-2 border-purple-400 rounded-xl p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="bg-purple-500 p-3 rounded-lg">
                  <Lock size={24} className="text-white" />
                </div>
                <h3 className="text-xl font-bold text-purple-300">Private Subnet Traffic</h3>
              </div>
              <div className="space-y-3 text-purple-200">
                <div className="flex items-start gap-2">
                  <span className="text-amber-400 font-bold">→</span>
                  <span>No direct internet access (secure!)</span>
                </div>
                <div className="flex items-start gap-2">
                  <span className="text-amber-400 font-bold">→</span>
                  <span>Outbound only via NAT Gateway</span>
                </div>
                <div className="flex items-start gap-2">
                  <span className="text-amber-400 font-bold">→</span>
                  <span>Hosts: Databases, App Servers, EKS Nodes</span>
                </div>
                <div className="flex items-start gap-2">
                  <span className="text-amber-400 font-bold">→</span>
                  <span>Route: <span className="font-mono text-amber-400">0.0.0.0/0 → NAT</span></span>
                </div>
              </div>
            </div>
          </div>

          {/* Key Concepts */}
          <div className="mt-8 bg-gradient-to-r from-slate-700 to-slate-800 border-2 border-slate-600 rounded-xl p-6">
            <h3 className="text-2xl font-bold text-white mb-4">🎯 Master These Concepts</h3>
            <div className="grid md:grid-cols-3 gap-6">
              <div>
                <div className="text-amber-400 font-bold mb-2">Why NAT in Public Subnet?</div>
                <div className="text-slate-300 text-sm">NAT Gateway needs a public IP and IGW access. It lives in public but ONLY serves private subnet traffic.</div>
              </div>
              <div>
                <div className="text-amber-400 font-bold mb-2">Why 2 Availability Zones?</div>
                <div className="text-slate-300 text-sm">High Availability! If one AZ fails, your app keeps running in the other AZ.</div>
              </div>
              <div>
                <div className="text-amber-400 font-bold mb-2">Route Table Association</div>
                <div className="text-slate-300 text-sm">Each subnet can have ONLY ONE route table. But one route table can serve MANY subnets.</div>
              </div>
            </div>
          </div>

          {/* CLI Commands */}
          <div className="mt-8 bg-slate-900 border-2 border-slate-700 rounded-xl p-6">
            <h3 className="text-xl font-bold text-white mb-4">🔧 Useful AWS CLI Commands</h3>
            <div className="grid md:grid-cols-2 gap-4">
              <div className="bg-slate-800 rounded p-3 font-mono text-sm">
                <div className="text-green-400 mb-1"># List all VPCs</div>
                <div className="text-slate-300">aws ec2 describe-vpcs</div>
              </div>
              <div className="bg-slate-800 rounded p-3 font-mono text-sm">
                <div className="text-green-400 mb-1"># List subnets</div>
                <div className="text-slate-300">aws ec2 describe-subnets</div>
              </div>
              <div className="bg-slate-800 rounded p-3 font-mono text-sm">
                <div className="text-green-400 mb-1"># Check route tables</div>
                <div className="text-slate-300">aws ec2 describe-route-tables</div>
              </div>
              <div className="bg-slate-800 rounded p-3 font-mono text-sm">
                <div className="text-green-400 mb-1"># Test internet from EC2</div>
                <div className="text-slate-300">curl ifconfig.me</div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}